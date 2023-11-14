import SwiftUI

struct IdeationView: View {
    @State var project: Project
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State var color: Color = .blue
    @State private var originalWidth: CGFloat = 0
    @State private var originalHeight: CGFloat = 0
    @StateObject var sharedViewModel = SharedViewModel()
    
    
    var body: some View {
        GeometryReader{ geometry in
            let circleSize = geometry.size.width * 0.9
            
            ZStack {
                ForEach((0..<4), id: \.self) { index in
                    FirstStageView(color: index.isMultiple(of: 2) ? .gray : .cyan, circleSize: .constant(circleSize))
                        .scaleEffect(currentIndex == index ? 0.8 : 1.3)
                        .offset(x: offset(index: index, geometry: geometry, circleSize: circleSize), y: 0)
                        .disabled(currentIndex != index)
                
                    
                }
                
                //Buttons
                HStack {
//                    Button(action: {
//                        withAnimation {
//                            currentIndex = max(0, currentIndex - 1)
//                        }
//                    }) {
//                        Image(systemName: "arrow.left")
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .padding()
//                    }
                    
                    Spacer()
                        .frame(width: geometry.size.width - 200, height: geometry.size.height / 2)
                    
                    Button(action: {
                        withAnimation {
                            currentIndex = min(4 - 1, currentIndex + 1)
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                    }
                }
                .foregroundColor(.white)
            }
            .padding()
            .frame(width: geometry.size.width, height: geometry.size.height)
        }

    }
    
    private func offset(index: Int, geometry: GeometryProxy, circleSize: CGFloat) -> CGFloat {
        let overlap = circleSize * 0.05
        return CGFloat(index - currentIndex) * (circleSize - overlap)
    }
}

// View for tests
struct CircleView: View {
    var color: Color
    @Binding var circleSize: CGFloat // Inicializa com um valor padrão
    @State var index : Int
    
    var body: some View {
        ZStack {
            Ellipse()
//            Circle()
                .foregroundColor(color)
                .frame(width: circleSize, height: circleSize * 1.2)

            VStack{
                Text("Etapa \(index + 1)") // Mostra o tamanho do círculo
                Text("Tamanho \(circleSize)")
            }
        }
    }
}

#Preview {
    GeometryReader{ geometry in
        let circleSize = geometry.size.width * 0.9
        CircleView(color: Color.blue, circleSize: .constant(circleSize), index: 1)
    }
}

