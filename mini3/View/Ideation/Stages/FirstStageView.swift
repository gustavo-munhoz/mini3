import SwiftUI
import Combine

struct FirstStageView: View {
    @State private var inputWord: String = ""
    @State private var wordPositions: [WordPosition] = []
    @State private var selectedWords: [WordPosition] = []
    @State private var errorMessage: String?
    @State private var error : Bool = false
    @State var color : Color
    @Binding var circleSize: CGFloat
    private let wordsService = WordsService.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Ellipse()
                    .foregroundColor(color)
                    .frame(width: circleSize, height: circleSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                TextField("...", text: $inputWord)
                    .font(.title)
                    .padding()
                    .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.2)
                    .background(.clear)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        let newWordPosition = generateNonOverlappingPosition(screenSize: geometry.size, word: inputWord, fontSize: calculateFontSize(screenSize: geometry.size))
                        if !inputWord.isEmpty {
                            selectedWords.append(newWordPosition)
                        }
                        fetchRelatedWords(geometry: geometry)
                        for i in selectedWords {
                            print(i.word)
                        }
                        inputWord = ""
                    }
                    .textFieldStyle(.plain)
                
                ForEach(wordPositions.filter { !selectedWords.contains($0) }) { wordPosition in
                    RelatedWordView(wordPosition: wordPosition,
                                    isSelected: false,
                                    fontSize: calculateFontSize(screenSize: geometry.size),
                                    onWordTapped: {
                                        withAnimation(.easeInOut(duration: 1)){
                                            handleWordSelection(wordPosition: wordPosition)
                                            fetchRelatedWords(with: wordPosition.word, geometry: geometry)
                                        }
                                    },
                                    rect: rectangleAroundString(at: CGPoint(x: wordPosition.relativeX, y: wordPosition.relativeY),
                                                                for: wordPosition.word,with: calculateFontSize(screenSize: geometry.size)))
                    .animation(.easeInOut(duration: 1), value: wordPosition.isVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if !selectedWords.contains(wordPosition) {
                                withAnimation(.easeOut(duration: 1)) {
                                    wordPosition.isVisible = false
                                }
                            }
                        }
                    }
                    .position(x: wordPosition.relativeX * geometry.size.width,
                              y: wordPosition.relativeY * geometry.size.height)
                }
                
                ForEach(selectedWords) { wordPosition in
                    RelatedWordView(
                        wordPosition: wordPosition,
                        isSelected: true,
                        fontSize: calculateFontSize(screenSize: geometry.size),
                        onWordTapped: {
                            withAnimation(.easeOut(duration: 1)){
                                handleWordSelection(wordPosition: wordPosition)
                            }
                        }, rect: rectangleAroundString(at: CGPoint(x: wordPosition.relativeX, y: wordPosition.relativeY), for: wordPosition.word, with: calculateFontSize(screenSize: geometry.size))
                    )
                    .position(x: wordPosition.relativeX * geometry.size.width,
                              y: wordPosition.relativeY * geometry.size.height)
                }
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }
    private func handleWordSelection(wordPosition: WordPosition) {
        if let index = selectedWords.firstIndex(where: { $0 == wordPosition }) {
            selectedWords.remove(at: index)
            wordPositions.removeAll { $0.id == wordPosition.id
            }
        } else {
            selectedWords.append(wordPosition)
        }
    }
    private func fetchRelatedWords(with word: String, geometry: GeometryProxy) {
        wordsService.fetchRelatedWords(word: word.capitalizedFirst()) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let words):
                    var delay = 0.0
                    for word in words {
                        delay += 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeInOut(duration: 1)) {
                                let wp = generateNonOverlappingPosition(screenSize: geometry.size, word: word.capitalizedFirst(), fontSize: calculateFontSize(screenSize: geometry.size))
                                if !self.selectedWords.contains(wp) {
                                    self.wordPositions.append(wp)
                                    wp.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                                        .autoconnect()
                                        .sink { _ in
                                            if !self.selectedWords.contains(wp) {
                                                self.wordPositions.removeAll { $0.id == wp.id }
                                            }
                                        }
                                }
                            }
                        }
                    }
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
                    var delay = 0.0
                    for word in words {
                        delay += 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeInOut(duration: 1)){
                                let wp = generateNonOverlappingPosition(screenSize: geometry.size, word: word.capitalizedFirst(), fontSize: calculateFontSize(screenSize: geometry.size))
                                if !self.selectedWords.contains(wp) {
                                    self.wordPositions.append(wp)
                                    wp.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                                        .autoconnect()
                                        .sink { _ in
                                            if !self.selectedWords.contains(wp) {
                                                self.wordPositions.removeAll { $0.id == wp.id }
                                            }
                                        }
                                }
                            }
                            
                        }
                    }
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
                for existingWordPosition in wordPositions {
                    let existingRect = rectangleAroundString(at: CGPoint(x: existingWordPosition.relativeX * screenSize.width, y: existingWordPosition.relativeY * screenSize.height), for: existingWordPosition.word, with: fontSize)
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

extension String {
    func capitalizedFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt((self.x - point.x) * (self.x - point.x) + (self.y - point.y) * (self.y - point.y))
    }
}



#Preview {
    FirstStageView(color: .gray ,circleSize: .constant(1000))
}