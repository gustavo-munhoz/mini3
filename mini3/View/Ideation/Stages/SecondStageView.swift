import SwiftUI
import Combine

struct SecondStageView: View {
    @EnvironmentObject var store: AppStore
    
    @State private var inputText: String = ""
    @State private var errorMessage: String?
    @State private var error : Bool = false
    @State var color : Color
    @Binding var circleSize: CGFloat
    private let chatGPTService = GPTService.shared
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Ellipse()
                    .foregroundColor(.black)
                    .overlay {
                        Circle()
                            .stroke(color, lineWidth: geometry.size.width * 0.002)
                            
                    }
                    .frame(width: circleSize, height: circleSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // MARK: - Appearing Concepts
                ForEach((store.state.currentProject?.appearingConcepts ?? []).filter { !(store.state.currentProject?.selectedConcepts ?? []).contains($0)}) { wordPosition in
                    ConceptView(model: wordPosition,isSelected: false,onSelected: {
                        withAnimation(.easeIn(duration: 1)){
                            store.dispatch(.selectConcept(wordPosition))
                            fetchConcepts(with: wordPosition.content, geometry: geometry)
                            
                        }
                    }, fontSize: calculateFontSize(screenSize: geometry.size))
                    .animation(.easeInOut(duration: 1), value: wordPosition.isVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if !(store.state.currentProject?.selectedConcepts ?? []).contains(wordPosition) {
                                withAnimation(.easeOut(duration: 1)) {
                                    wordPosition.isVisible = false
                                }
                            }
                        }
                    }
                    .position(x: wordPosition.relativeX * geometry.size.width,
                              y: wordPosition.relativeY * geometry.size.height)
                }
                
                // MARK: - Selected Concepts
                ForEach((store.state.currentProject?.selectedConcepts ?? [])) { wordPosition in
                    ConceptView(
                        model: wordPosition,
                        isSelected: true,
                        onSelected: {
                            withAnimation(.easeOut(duration: 1)){
                                store.dispatch(.selectConcept(wordPosition))
                            }
                        }, fontSize: calculateFontSize(screenSize: geometry.size))
                    .position(x: wordPosition.relativeX * geometry.size.width,
                              y: wordPosition.relativeY * geometry.size.height)
                }
                
                // MARK: - Input Concept
                TextView(color: color, geometry: geometry, onSend: { text in
                    inputText = text
                    let newWordPosition = generateNonOverlappingPosition(screenSize: geometry.size, word: inputText, fontSize: calculateFontSize(screenSize: geometry.size))
                    if !inputText.isEmpty {
                        store.dispatch(.selectConcept(newWordPosition))
                    }
                    fetchConcepts(with: inputText, geometry: geometry)
                    inputText = ""
                }, placeholder: "Write your suggestions here...")
                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.01))
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }
    
    
//    private func handleWordSelection(concept: ConceptPosition) {
//        if let index = selectedWords.firstIndex(where: { $0 == concept }) {
//            selectedWords.remove(at: index)
//            concepts.removeAll { $0.id == concept.id
//            }
//        } else {
//            selectedWords.append(concept)
//        }
//    }
    private func fetchConcepts(with concept: String, geometry: GeometryProxy) {
        let system = chatGPTService.createMessage(withRole: "system", content: Secrets.PROMPT_1)
        guard var wordPositions = store.state.currentProject?.selectedWords else { return }
        
        
        let words = chatGPTService.createMessage(
            withRole: "User",
            content: "\(wordPositions.map { $0.content }.joined(separator: ","))")
        let message = chatGPTService.createMessage(withRole: "user", content: "sentence: \(concept)")
        
        chatGPTService.chatGPT(messages: [system, message]) { result in
            switch result {
            case .success(let result):
                let gptConcepts = chatGPTService.extractConcepts(from: result)
                switch gptConcepts {
                case .success(let jsonConcepts):
                    var delay = 0.0
                    for concept in jsonConcepts {
                        delay += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeIn(duration: 1)) {
                                let conceptPosition = generateNonOverlappingPosition(screenSize: geometry.size, word: concept, fontSize: calculateFontSize(screenSize: geometry.size))
                                store.dispatch(.showConcept(conceptPosition))
                            }
                        }
                    }
                case .failure(let error):
                    print("JSON to string error: \(error)")
                }
            case .failure(let error):
                print("API call error: \(error)")
            }
        }
    }
    
    
    func calculateFontSize(screenSize: CGSize) -> CGFloat {
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
    func generateNonOverlappingPosition(screenSize: CGSize, word: String, fontSize: CGFloat) -> ConceptPosition {
        let circleCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let circleRadius = circleSize / 2
        
        // Tente encontrar uma posição não sobreposta um número limitado de vezes
        for _ in 0..<100000 {
            let randomPoint = randomPointInCircle(center: circleCenter, radius: circleRadius)
            let wordRect = rectangleAroundString(at: randomPoint, for: word, with: fontSize)
            
            // Verifique se o retângulo da palavra está dentro do círculo
            if isRectangleInsideCircle(wordRect, inCircle: circleCenter, radius: circleRadius) {
                var overlapFound = false
                
                // Verifique se o novo retângulo se sobrepõe a algum dos retângulos existentes
                for existingWordPosition in (store.state.currentProject?.appearingConcepts ?? []) {
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
                    return ConceptPosition(content: word, relativeX: relativeX, relativeY: relativeY)
                }
            }
        }
        
        // Se todas as tentativas falharem, retorne uma posição padrão (centro, por exemplo)
        return ConceptPosition(content: word, relativeX: 0.5, relativeY: 0.5)
    }
}
