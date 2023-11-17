import SwiftUI
import Combine

struct ThirdStageView: View {
    @EnvironmentObject var store: AppStore
    
    @State private var inputText: String = ""
    @State private var errorMessage: String?
    @State private var error : Bool = false
    @State var color : Color
    @Binding var circleSize: CGFloat
    @State var positions: [CGPoint] = []
    private let youtubeService = YoutubeService.shared
    
    
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
                ForEach((store.state.currentProject?.appearingVideos ?? []).filter { !(store.state.currentProject?.selectedVideos ?? []).contains($0)}) { videoPosition in
                    YoutubeView(video: videoPosition, isSelected: false, fontSize: calculateFontSize(screenSize: geometry.size), screenSize: geometry.size, onSelected: {
                            //Touch
                            fetchVideos(with: videoPosition.title, geometry: geometry)
                    })
                    .animation(.easeInOut(duration: 1), value: videoPosition.isVisible)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            if !(store.state.currentProject?.selectedVideos ?? []).contains(videoPosition) {
                                withAnimation(.easeOut(duration: 1)) {
                                    videoPosition.isVisible = false
                                }
                            }
                        }
                    }
                    .position(x: videoPosition.relativeX * geometry.size.width,
                              y: videoPosition.relativeY * geometry.size.height)
                }
                
                
                
                
                // MARK: - Selected Concepts
                ForEach((store.state.currentProject?.selectedVideos ?? [])) { videoPosition in
                    YoutubeView(
                        video: videoPosition, isSelected: true, fontSize: calculateFontSize(screenSize: geometry.size), screenSize: geometry.size,
                        onSelected: {
                            print("deselect")
                            withAnimation(.easeOut(duration: 1)){
                                store.dispatch(.hideVideo(videoPosition))
                            }
                        })
                    .position(x: videoPosition.relativeX * geometry.size.width,
                              y: videoPosition.relativeY * geometry.size.height)
                }
                
                // MARK: - Input Concept
                TextView(color: color, geometry: geometry, onSend: { text in
                    inputText = text
                    fetchVideos(with: inputText, geometry: geometry)
                    inputText = ""
                }, placeholder: "...")
                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.01))
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }
    
    // Testando outra altenativa de posicionar
    private func positionForIndex(_ index: Int, total: Int, startAngle: CGFloat = 0, screenSize: CGSize) -> CGPoint {
        let angle = (2 * .pi / CGFloat(total)) * CGFloat(index) + startAngle
        return CGPoint(x: (circleSize / 2) * cos(angle) + screenSize.width / 2,
                       y: (circleSize / 2) * sin(angle) + screenSize.height / 2)
    }
    
    
    private func fetchVideos(with searchQuery: String, geometry: GeometryProxy) {
        youtubeService.fetch(using: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    var delay = 0.0
                    for item in items {
                        delay += 1
                        let pos = generateNonOverlappingPosition(screenSize: geometry.size, fontSize: calculateFontSize(screenSize: geometry.size))
                        let video = item.toSimpleVideo()
                        video.relativeX = pos.x
                        video.relativeY = pos.y
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeIn(duration: 1)) {
//                                store.dispatch(.showVideo(video))
                                handleVideoAppearance(videoPosition: video)
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                    self.errorMessage = error.localizedDescription
                    self.error = true
                }
            }
        }
    }
    

    private func handleVideoAppearance(videoPosition: VideoPosition) {
        if !(store.state.currentProject?.selectedVideos.contains(videoPosition) ?? false) {
            store.dispatch(.showVideo(videoPosition))
            videoPosition.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if !(store.state.currentProject?.selectedVideos.contains(videoPosition) ?? false) {
                        store.dispatch(.hideVideo(videoPosition))
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
        return CGPoint(x: 0.5, y: 0.5)
    }

}
