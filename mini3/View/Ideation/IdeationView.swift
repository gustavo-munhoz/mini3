import SwiftUI

struct IdeationView: View {
    @EnvironmentObject var store: AppStore
    @State var project: Project
    @State private var currentIndex: Int = 0
    @State var color: Color = .blue
    @State private var originalWidth: CGFloat = 0
    @State private var originalHeight: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    
    var body: some View {
        GeometryReader{ geometry in
            let circleSize = geometry.size.width * 0.9
            let stages = [
                IdentifiableView(FirstStageView(color: .appPink, circleSize: .constant(circleSize))),
                IdentifiableView(SecondStageView(color: .appPurple, circleSize: .constant(circleSize))),
                IdentifiableView(ThirdStageView(color: .appBlue, circleSize: .constant(circleSize)))
            ]
            
            ZStack {
                if currentIndex == 3 {
                    ZStack{
                        ThirdStageView(color: .appBlue, circleSize: .constant(circleSize))
                            .scaleEffect(0.8)
                            .disabled(true)
                        SecondStageView(color: .appPurple, circleSize: .constant(circleSize))
                            .scaleEffect(0.4)
                            .disabled(true)
                        FirstStageView(color: .appPink, circleSize: .constant(circleSize))
                            .scaleEffect(0.2)
                            .disabled(true)
                    }
                    
                } else {
                    ForEach((0..<3), id: \.self) { index in
                        stages[index].view
                            .scaleEffect(currentIndex == index ? 0.8 : 1.3)
                            .offset(x: offset(index: index, geometry: geometry, circleSize: circleSize), y: 0)
                            .disabled(currentIndex != index)
                    }
                }
            
            
//            ZStack{
//                ForEach((0..<3), id: \.self) { index in
//                    stages[index].view
//                        .scaleEffect(currentIndex == index ? 0.8 : 1.3)
//                        .offset(x: offset(index: index, geometry: geometry, circleSize: circleSize), y: 0)
//                        .disabled(currentIndex != index)
//                }
//                
                //Buttons
                HStack {
                    Button(action: {
                        withAnimation {
                            
                            currentIndex = max(0, currentIndex - 1)
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                    }
                    
                    Spacer()
                        .frame(width: geometry.size.width - 200, height: geometry.size.height / 2)
                    
                    Button(action: {
                        if currentIndex == 2 {
                            store.dispatch(.show(true))
                        } else {
                            store.dispatch(.show(false))
                        }
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

struct IdentifiableView: Identifiable {
    let id = UUID()
    let view: AnyView

    init<Content: View>(_ view: Content) {
        self.view = AnyView(view)
    }
}

