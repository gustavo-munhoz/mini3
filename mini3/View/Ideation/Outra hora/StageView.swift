import SwiftUI
import Combine

class SharedViewModel: ObservableObject {
    @Published var stageContent: [any Positionable] = []
}

struct StageView<Content: Positionable, S: Service, TypeView: ViewRepresentable>: View {
    @State private var views: [Content] = []
    @State private var selectedViews: [Content] = []
    @State private var errorMessage: String?
    @State private var error: Bool = false
    @State var color: Color
    @Binding var circleSize: CGFloat
    @ObservedObject var sharedViewModel: SharedViewModel
    let service: S
    var onSend: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Ellipse()
                    .foregroundColor(.black)
                    .frame(width: circleSize, height: circleSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                ForEach(sharedViewModel.stageContent, id: \.id) { content in
                    createContentView(content: content as! Content, geometry: geometry)
                        .animation(.easeInOut(duration: 1), value: content.isVisible)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation(.easeOut(duration: 1)) {
                                    content.isVisible = false
                                }
                            }
                        }
                        .position(x: content.relativeX * geometry.size.width, y: content.relativeY * geometry.size.height)
                    
                }
//                TextView(color: color, geometry: geometry, onSend: { text in
//                    onSend(text)
//                    
//                    for i in selectedViews {
//                        print(i.content)
//                    }
//                })
                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.01))
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }
    
    @ViewBuilder
    private func createContentView(content: Content, geometry: GeometryProxy) -> some View {
        let position = generateNonOverlappingPosition(screenSize: geometry.size, word: content.content, fontSize: calculateFontSize(screenSize: geometry.size))

        switch content {
        case let wordContent as WordPosition:
            // Renderize a view para WordPosition
            Text(wordContent.content)
                .position(position)
                // ... outras configurações para WordPosition ...

        case let conceptContent as ConceptPosition:
            ConceptView(model:
                            ConceptPosition(content: conceptContent.content, relativeX: conceptContent.relativeX, relativeY: conceptContent.relativeY),
                        isSelected: false,
                        onSelected: {
                print("Concept")
            },
                        fontSize: calculateFontSize(screenSize: geometry.size))

        // Repita para outros tipos de conteúdo
        default:
            EmptyView()
        }
    }
    
    func updateViews(withNewContent newContent: [Content]) {
        self.views.append(contentsOf: newContent)
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
    func generateNonOverlappingPosition(screenSize: CGSize, word: String, fontSize: CGFloat) -> CGPoint {
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
                for existingWordPosition in views {
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
                    return CGPoint(x: relativeX, y: relativeY)
                }
            }
        }
        
        // Se todas as tentativas falharem, retorne uma posição padrão (centro, por exemplo)
        return CGPoint(x: 0.5, y: 0.5)
    }
}

//
//extension Content where Self: Positionable {
//    mutating func startTimer() {
//        self.cancellable = Timer.publish(every: 8, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                // Atualize o estado ou execute ações aqui
//                self?.isVisible = false
//                // Adicione qualquer outra lógica necessária
//            }
//    }
//}



//#Preview {
//    StageView(color: .appPink ,circleSize: .constant(1000), service: <#Service#>)
//}
