import SwiftUI
import Combine

struct FourthStageView: View {
    @EnvironmentObject var store: AppStore
    
    @State private var ideaViewSizes: [UUID: CGSize] = [:]
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
                
                // MARK: - Appearing Ideas
                ForEach((store.state.currentProject?.appearingIdeas ?? []).filter { !(store.state.currentProject?.finalIdea ?? []).contains($0)}) { ideaPosition in
                    
                    IdeaView(model: ideaPosition, isSelected: false, fontSize: calculateFontSize(screenSize: geometry.size)){
                        withAnimation(.easeIn(duration: 1)){
//                            store.dispatch(.selectIdea(ideaPosition))
                            if (store.state.currentProject?.appearingIdeas.count ?? 0) <= 4 {
                                fetchIdeas(with: ideaPosition.idea , geometry: geometry)
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if !(store.state.currentProject?.finalIdea ?? []).contains(ideaPosition) {
                                withAnimation(.easeOut(duration: 1)) {
                                    ideaPosition.isVisible = false
                                }
                            }
                        }
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                let size = geo.size
                                ideaViewSizes[ideaPosition.id] = size
                                if !ideaPosition.isPositioned {
                                    positionIdeaView(ideaPosition, screenSize: geometry.size, ideaPositions: store.state.currentProject?.appearingIdeas ?? [], size: size)
                                }
                            }
                        }
                    )
                    .position(x: ideaPosition.relativeX * geometry.size.width,
                              y: ideaPosition.relativeY * geometry.size.height)
                    .opacity(ideaPosition.isVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: ideaPosition.isVisible)
                }
            
                // MARK: - Selected Concepts
                ForEach((store.state.currentProject?.finalIdea ?? [])) { ideaPosition in
                    IdeaView(model: ideaPosition, isSelected: true, fontSize: calculateFontSize(screenSize: geometry.size), onSelected: {
                        withAnimation {
                            store.dispatch(.selectIdea(ideaPosition))
                        }
                    })
                    .position(x: ideaPosition.relativeX * geometry.size.width,
                              y: ideaPosition.relativeY * geometry.size.height)
                }
                
                // MARK: - Input Concept
                TextView(color: color, geometry: geometry, onSend: { text in
                    inputText = text
                    fetchIdeas(with: inputText, geometry: geometry)
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
        if !(store.state.currentProject?.finalIdea.contains(ideaPosition) ?? false) {
            store.dispatch(.showIdea(ideaPosition))
            ideaPosition.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if !(store.state.currentProject?.finalIdea.contains(ideaPosition) ?? false) {
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

    
    
    func positionIdeaView(_ ideaPosition: IdeaPosition, screenSize: CGSize, ideaPositions: [IdeaPosition], size: CGSize) {
        while true {
            // Gerar posição aleatória
            let maxX = screenSize.width * 0.75 // 80% da largura da tela
            let maxY = screenSize.height * 0.20

            let randomPoint = randomPointInCircle(center: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2), radius: screenSize.width / 2, maxX: maxX, maxY: maxY)

            let conceptRect = CGRect(x: randomPoint.x, y: randomPoint.y, width: size.width, height: size.height)
            
            // Verificar se há sobreposição
            var hasOverlap = false
            for otherConcept in ideaPositions where otherConcept !== ideaPosition {
                if let otherSize = ideaViewSizes[otherConcept.id] {
                    let otherRect = CGRect(x: otherConcept.relativeX * screenSize.width, y: otherConcept.relativeY * screenSize.height, width: otherSize.width, height: otherSize.height)
                    if conceptRect.intersects(otherRect) {
                        hasOverlap = true
                        break
                    }
                }
            }
            
            if !hasOverlap {
                // Atualizar posição se não houver sobreposição
                ideaPosition.setPosition(relativeX: randomPoint.x / screenSize.width, relativeY: randomPoint.y / screenSize.height)
                ideaPosition.isPositioned = true
                break
            }
        }
        
        DispatchQueue.main.async {
            withAnimation {
                ideaPosition.isVisible = true
            }
        }
    }
    

}
