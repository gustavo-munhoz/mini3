import SwiftUI
import Combine

struct SecondStageView: View {
    @EnvironmentObject var store: AppStore
    
    @State private var conceptViewSizes: [UUID: CGSize] = [:]
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
                    .foregroundColor(.appBlack)
                    .overlay {
                        Circle()
                            .stroke(color, lineWidth: geometry.size.width * 0.002)
                    }
                    .frame(width: circleSize, height: circleSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // MARK: - Appearing Concepts
                ForEach((store.state.currentProject?.appearingConcepts ?? []).filter { !(store.state.currentProject?.selectedConcepts ?? []).contains($0)}) { conceptPosition in
                    
                    ConceptView(model: conceptPosition, isSelected: false, fontSize: calculateFontSize(screenSize: geometry.size), 
                                onSelected: {
                        withAnimation(.easeIn(duration: 1)){
                            store.dispatch(.selectConcept(conceptPosition))
                            if (store.state.currentProject?.appearingConcepts.count ?? 0) <= 10 {
                                fetchConcepts(with: conceptPosition.content, geometry: geometry)
                            }
                        }
                    })
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if !(store.state.currentProject?.selectedConcepts ?? []).contains(conceptPosition) {
                                withAnimation(.easeOut(duration: 1)) {
                                    conceptPosition.isVisible = false
                                }
                            }
                        }
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                let size = geo.size
                                conceptViewSizes[conceptPosition.id] = size
                                if !conceptPosition.isPositioned {
                                    positionConceptView(conceptPosition, screenSize: geometry.size, conceptViews: store.state.currentProject?.appearingConcepts ?? [], size: size)
                                }
                            }
                        }
                    )
                    .position(x: conceptPosition.relativeX * geometry.size.width,
                              y: conceptPosition.relativeY * geometry.size.height)
                    .opacity(conceptPosition.isVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: conceptPosition.isVisible)
                }
                
                // MARK: - Selected Concepts
                ForEach((store.state.currentProject?.selectedConcepts ?? [])) { conceptPosition in
                    ConceptView(
                        model: conceptPosition,
                        isSelected: true,
                        fontSize: calculateFontSize(screenSize: geometry.size), onSelected: {
                            withAnimation(.easeOut(duration: 1)){
                                store.dispatch(.selectConcept(conceptPosition))
                            }
                        })
                    .position(x: conceptPosition.relativeX * geometry.size.width,
                              y: conceptPosition.relativeY * geometry.size.height)
                }
                
                // MARK: - Input Concept
                TextView(color: color, geometry: geometry, onSend: { text in
                    inputText = text
                    let newConceptPosition = ConceptPosition(word: text)
                    if !inputText.isEmpty {
                        store.dispatch(.selectConcept(newConceptPosition))
                    }
                    fetchConcepts(with: inputText, geometry: geometry)
                    inputText = ""
                }, placeholder: "Write your suggestions here...")
                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.01))
            }
            .onChange(of: store.state.currentProject?.currentStage) { oldValue, newValue in
                if newValue == IdeationStage.concepts {
                    fetchConcepts(with: "", geometry: geometry)
                }
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }

    private func fetchConcepts(with concept: String, geometry: GeometryProxy) {
        let system = chatGPTService.createMessage(withRole: "system", content: Secrets.PROMPT_1)
        guard let wordPositions = store.state.currentProject?.selectedWords else { return }
        let words = chatGPTService.createMessage(
            withRole: "user",
            content: "Words to use: \(wordPositions.map { $0.content }.joined(separator: ","))")
        let message = chatGPTService.createMessage(withRole: "user", content: "sentence: \(concept)")
        
        chatGPTService.chatGPT(messages: [system, words, message]) { result in
            print(result)
            switch result {
            case .success(let result):
                let gptConcepts = chatGPTService.extractConcepts(from: result)
                print(gptConcepts)
                switch gptConcepts {
                case .success(let jsonConcepts):
                    
                    var delay = 0.0
                    for concept in jsonConcepts {
                        delay += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeIn(duration: 1)) {
                                let conceptPosition = ConceptPosition(word: concept)
                                store.dispatch(.showConcept(conceptPosition))
                                handleConceptAppearance(conceptPosition: conceptPosition)
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
    
    private func handleConceptAppearance(conceptPosition: ConceptPosition) {
        if !(store.state.currentProject?.selectedConcepts.contains(conceptPosition) ?? false) {
            store.dispatch(.showConcept(conceptPosition))
            conceptPosition.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if !(store.state.currentProject?.selectedConcepts.contains(conceptPosition) ?? false) {
                        store.dispatch(.hideConcept(conceptPosition))
                    }
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
    
    func randomPointInCircle(center: CGPoint, radius: CGFloat, maxX: CGFloat, maxY: CGFloat) -> CGPoint {
        var randomPoint: CGPoint
        
        repeat {
            let angle = CGFloat.random(in: 0..<2 * .pi)
            let randomRadius = CGFloat.random(in: 0..<radius)
            randomPoint = CGPoint(
                x: center.x + randomRadius * cos(angle),
                y: center.y + randomRadius * sin(angle)
            )
        } while randomPoint.x > maxX || randomPoint.y < maxY
        return randomPoint
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
    
    func positionConceptView(_ conceptPosition: ConceptPosition, screenSize: CGSize, conceptViews: [ConceptPosition], size: CGSize) {
        while true {
            // Gerar posição aleatória
            let maxX = screenSize.width * 0.8 // 80% da largura da tela
            let maxY = screenSize.height * 0.15

            let randomPoint = randomPointInCircle(center: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2), radius: screenSize.width / 2, maxX: maxX, maxY: maxY)

            let conceptRect = CGRect(x: randomPoint.x, y: randomPoint.y, width: size.width, height: size.height)
            
            // Verificar se há sobreposição
            var hasOverlap = false
            for otherConcept in conceptViews where otherConcept !== conceptPosition {
                if let otherSize = conceptViewSizes[otherConcept.id] {
                    let otherRect = CGRect(x: otherConcept.relativeX * screenSize.width, y: otherConcept.relativeY * screenSize.height, width: otherSize.width, height: otherSize.height)
                    if conceptRect.intersects(otherRect) {
                        hasOverlap = true
                        break
                    }
                }
            }
            
            if !hasOverlap {
                // Atualizar posição se não houver sobreposição
                conceptPosition.setPosition(relativeX: randomPoint.x / screenSize.width, relativeY: randomPoint.y / screenSize.height)
                conceptPosition.isPositioned = true
                break
            }
        }
        
        DispatchQueue.main.async {
            withAnimation {
                conceptPosition.isVisible = true
            }
        }
    }
}
