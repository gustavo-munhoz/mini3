import SwiftUI
import Combine

struct FirstStageView: View {
    @EnvironmentObject var store: AppStore
    
    @State private var inputWord: String = ""
    @State private var errorMessage: String?
    @State private var error : Bool = false
    @State var color : Color
    @Binding var circleSize: CGFloat
    private let wordsService = WordsService.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                // MARK: - Background
                Ellipse()
                    .foregroundColor(.appBlack)
                    .overlay {
                        Circle()
                            .stroke(color, lineWidth: geometry.size.width * 0.002)
                    }
                    .frame(width: circleSize, height: circleSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // MARK: - Appearing words
                ForEach((store.state.currentProject?.appearingWords ?? []).filter { !(store.state.currentProject?.selectedWords ?? []).contains($0) }) { wordPosition in
                    RelatedWordView(model: wordPosition,isSelected: false,fontSize: calculateFontSize(screenSize: geometry.size),
                                onSelected: {
                                    withAnimation(.easeInOut(duration: 1)){
                                        store.dispatch(.selectWord(wordPosition))
                                        fetchRelatedWords(with: wordPosition.content, geometry: geometry)
                                    }
                                })
                    .animation(.easeInOut(duration: 1), value: wordPosition.isVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if !(store.state.currentProject?.selectedWords ?? []).contains(wordPosition) {
                                withAnimation(.easeOut(duration: 1)) {
                                    wordPosition.isVisible = false
                                }
                            }
                        }
                    }
                    .position(x: wordPosition.relativeX * geometry.size.width,
                              y: wordPosition.relativeY * geometry.size.height)
                }
                
                // MARK: - Selected words
                ForEach((store.state.currentProject?.selectedWords ?? [])) { wordPosition in
                    RelatedWordView(
                        model: wordPosition,
                        isSelected: true,
                        fontSize: calculateFontSize(screenSize: geometry.size),
                        onSelected: {
                            withAnimation(.easeOut(duration: 1)){
                                store.dispatch(.selectWord(wordPosition))
                            }
                        })
                    .position(x: wordPosition.relativeX * geometry.size.width,
                              y: wordPosition.relativeY * geometry.size.height)
                }
                
                // MARK: - Input words

                TextView(color: .appPink, geometry: geometry, onSend: { text in
                    inputWord = text.capitalizedFirst()
                    let newWordPosition = generateNonOverlappingPosition(screenSize: geometry.size, word: inputWord, fontSize: calculateFontSize(screenSize: geometry.size))
                    if !inputWord.isEmpty {
                        store.dispatch(.selectWord(newWordPosition))
                    }
                    fetchRelatedWords(geometry: geometry)
                    inputWord = ""
                }, placeholder: "Write your word ideas here...")
                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.01))
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Error"), message: Text("We don't have any suggestions.\n Sorry :("), dismissButton: .default(Text("OK")))
        })
    }
    
    private func handleFetchedWords(words: [String], geometry: GeometryProxy) {
        var delay = 0.0
        for word in words {
            delay += 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 1)) {
                    let wp = generateNonOverlappingPosition(
                        screenSize: geometry.size,
                        word: word.capitalizedFirst(),
                        fontSize: calculateFontSize(screenSize: geometry.size)
                    )
                    handleWordAppearance(wordPosition: wp)
                }
            }
        }
    }

    private func handleWordAppearance(wordPosition: WordPosition) {
        if !(store.state.currentProject?.selectedWords.contains(wordPosition) ?? false) {
            store.dispatch(.showWord(wordPosition))
            wordPosition.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if !(store.state.currentProject?.selectedWords.contains(wordPosition) ?? false) {
                        store.dispatch(.hideWord(wordPosition))
                    }
                }
        }
    }

    private func fetchRelatedWords(with word: String, geometry: GeometryProxy) {
        wordsService.fetchRelatedWords(word: word.capitalizedFirst()) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let words):
                    handleFetchedWords(words: words, geometry: geometry)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.error = true
                }
            }
        }
    }

    private func fetchRelatedWords(geometry: GeometryProxy) {
        guard !inputWord.isEmpty else {
            self.error = true
            self.errorMessage = "Por favor, insira uma palavra."
            return
        }
        
        wordsService.fetchRelatedWords(word: inputWord) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let words):
                    handleFetchedWords(words: words, geometry: geometry)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.error = true
                }
            }
        }
    }
    
    private func calculateFontSize(screenSize: CGSize) -> CGFloat {
        let baseFontSize: CGFloat = 8 // Tamanho base para a fonte
        let scaleFactor: CGFloat = 0.02 // Fator de escalonamento para ajustar o tamanho da fonte com base na tela
        
        // Use o menor entre a largura e a altura para o escalonamento para garantir que a fonte se ajuste bem em ambas as dimensões
        let scalingDimension = min(screenSize.width, screenSize.height)
        
        // Calcule o tamanho da fonte ajustado
        let adjustedFontSize = baseFontSize + (scalingDimension * scaleFactor)
        
        return adjustedFontSize
    }
    
    func randomPointInCircle(center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = CGFloat.random(in: 0..<2 * .pi)
        let randomRadius = CGFloat.random(in: 0..<radius)
        return CGPoint(
            x: center.x + randomRadius * cos(angle),
            y: center.y + randomRadius * sin(angle)
        )
    }
    
    func rectangleAroundString(at point: CGPoint, for word: String, with fontSize: CGFloat) -> CGRect {
        let estimatedWidth = CGFloat(word.count) * fontSize// Ajuste conforme a fonte
        let estimatedHeight = fontSize// Ajuste conforme a fonte
        let rect = CGRect(x: point.x - estimatedWidth / 2, y: point.y - estimatedHeight / 2, width: estimatedWidth, height: estimatedHeight)
        return rect
    }
    
    func isRectangleInsideCircle(_ rect: CGRect, inCircle center: CGPoint, radius: CGFloat) -> Bool {
        // Encontrar o ponto no retângulo mais distante do centro do círculo
        let furthestPoint = CGPoint(
            x: max(abs(rect.minX - center.x), abs(rect.maxX - center.x)),
            y: max(abs(rect.minY - center.y), abs(rect.maxY - center.y))
        )
        
        // Calcular a distância desse ponto ao centro
        let distanceToFurthestPoint = sqrt(pow(furthestPoint.x, 2) + pow(furthestPoint.y, 2))
        
        // Se a distância for menor que o raio, então o retângulo está dentro do círculo
        return distanceToFurthestPoint <= radius
    }
    
    func doRectanglesOverlap(_ rect1: CGRect, _ rect2: CGRect) -> Bool {
        print(rect1.intersects(rect2))
        return rect1.intersects(rect2)
    }
    
    func generateNonOverlappingPosition(screenSize: CGSize, word: String, fontSize: CGFloat) -> WordPosition {
        let circleCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let circleRadius = circleSize / 2
        
        // Tente encontrar uma posição não sobreposta um número limitado de vezes
        for _ in 0..<10000 {
            let randomPoint = randomPointInCircle(center: circleCenter, radius: circleRadius)
            let wordRect = rectangleAroundString(at: randomPoint, for: word, with: fontSize)
            
            // Verifique se o retângulo da palavra está dentro do círculo
            if isRectangleInsideCircle(wordRect, inCircle: circleCenter, radius: circleRadius) {
                var overlapFound = false
                
                // Verifique se o novo retângulo se sobrepõe a algum dos retângulos existentes
                for existingWordPosition in (store.state.currentProject?.appearingWords ?? []) {
                    let existingRect = rectangleAroundString(at: CGPoint(x: existingWordPosition.relativeX * screenSize.width, y: existingWordPosition.relativeY * screenSize.height), for: existingWordPosition.content, with: fontSize)
                    if wordRect.intersects(existingRect) {
                        overlapFound = true
                        break
                    }
                }
                
                // Se não houver sobreposição, esta é uma posição válida
                if !overlapFound {
                    let relativeX = randomPoint.x / screenSize.width
                    let relativeY = randomPoint.y / screenSize.height
                    return WordPosition(word: word, relativeX: relativeX, relativeY: relativeY)
                }
            }
        }
        
        // Se todas as tentativas falharem, retorne uma posição padrão (centro, por exemplo)
        return WordPosition(word: word, relativeX: 0.5, relativeY: 0.5)
    }
}
