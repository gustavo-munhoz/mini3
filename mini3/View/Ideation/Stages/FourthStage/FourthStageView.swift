import SwiftUI
import Combine

struct FourthStageView: View {
    @EnvironmentObject var store: AppStore
    
    @State private var inputText: String = ""
    @State private var errorMessage: String?
    @State private var error : Bool = false
    @State var color : Color = .appYellow
    @Binding var circleSize: CGFloat
    @State var positions: [CGPoint] = []
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
                
                // MARK: - Appearing Videos
                ForEach(store.state.currentProject?.appearingIdeas ?? []) { ideaPosition in
                    IdeaView(model: ideaPosition, isSelected: false, fontSize: calculateFontSize(screenSize: geometry.size)) {
                        print("selected")
                    }
                    .animation(.easeInOut(duration: 1), value: ideaPosition.isVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                            withAnimation(.easeOut(duration: 1)) {
                                ideaPosition.isVisible = false
                                
                            }
                        }
                    }
                    .position(x: ideaPosition.relativeX * geometry.size.width,
                              y: ideaPosition.relativeY * geometry.size.height)
                }
                
            
                
                // MARK: - Input Concept
                TextView(color: color, geometry: geometry, onSend: { text in
                    inputText = text
//                    fetchVideos(with: inputText, geometry: geometry)
                    inputText = ""
                }, placeholder: "...")
                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.01))
            }
            .onChange(of: store.state.currentProject?.currentStage) { oldValue, newValue in
                if newValue == IdeationStage.ideas {
                    fetchIdeas(with: "", geometry: geometry)
                }
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }
    
    // Testando outra altenativa de posicionar
        

    private func fetchIdeas(with concept: String, geometry: GeometryProxy) {
        let system = chatGPTService.createMessage(withRole: "system", content: Secrets.PROMPT_2)
        guard let conceptPositions = store.state.currentProject?.selectedConcepts else { return }
        guard let videos = store.state.currentProject?.selectedVideos else { return }
        
        let concepts = chatGPTService.createMessage(
            withRole: "user",
            content: "concepts: \(conceptPositions.map { $0.content }.joined(separator: ","))")
        let videosTitle = chatGPTService.createMessage(
            withRole: "user",
            content: "videos Titles: \(videos.map { $0.title }.joined(separator: ","))")
        
        let message = chatGPTService.createMessage(withRole: "user", content: "sentence: \(concept)")
        
        chatGPTService.chatGPT(messages: [system, concepts, videosTitle, message]) { result in
            print(result)
            switch result {
            case .success(let result):
                let gptConcepts = chatGPTService.convertToIdeaResponses(from: result)
                print(gptConcepts)
                switch gptConcepts {
                case .success(let jsonConcepts):
                    var delay = 0.0
                    for ideaPosition in jsonConcepts {
                        delay += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeIn(duration: 1)) {
//                                let conceptPosition = generateNonOverlappingPosition(screenSize: geometry.size, word: concept, fontSize: calculateFontSize(screenSize: geometry.size))
//                                store.dispatch(.showConcept(conceptPosition))
                                
                                handleConceptAppearance(ideaPosition: IdeaPosition(idea: ideaPosition.idea, explanation: ideaPosition.explain, relativeX: 0, relativeY: 0))
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
    
    private func handleConceptAppearance(ideaPosition: IdeaPosition) {
        if !(store.state.currentProject?.finalIdea == ideaPosition) {
            store.dispatch(.showIdea(ideaPosition))
            ideaPosition.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if !(store.state.currentProject?.finalIdea == ideaPosition) {
                        store.dispatch(.hideIdea(ideaPosition))
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
    func generateNonOverlappingPosition(screenSize: CGSize, fontSize: CGFloat) -> CGPoint {
        let circleCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let circleRadius = circleSize / 2

        // Tente encontrar uma posição não sobreposta um número limitado de vezes
        for _ in 0..<100000 {
            let randomPoint = randomPointInCircle(center: circleCenter, radius: circleRadius)
            if !positions.contains(randomPoint) {
                self.positions.append(CGPoint(x: randomPoint.x / screenSize.width, y: randomPoint.y / screenSize.height))
                return CGPoint(x: randomPoint.x / screenSize.width, y: randomPoint.y / screenSize.height)
            }
        }
        // Se todas as tentativas falharem, retorne uma posição padrão (centro, por exemplo)
        return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }

}
