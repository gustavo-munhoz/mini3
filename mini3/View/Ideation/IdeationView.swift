import SwiftUI

struct IdeationView: View {
    @EnvironmentObject var store: AppStore
    
    @State var project: Project
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    
    var body: some View {
        GeometryReader{ geometry in
            let circleSize = geometry.size.width * 0.9
            let stages = [
                IdentifiableView(FirstStageView(color: .appPink, circleSize: .constant(circleSize))),
                IdentifiableView(SecondStageView(color: .appPurple, circleSize: .constant(circleSize))),
                IdentifiableView(ThirdStageView(color: .appBlue, circleSize: .constant(circleSize))),
                IdentifiableView(FourthStageView(circleSize: .constant(circleSize)))
            ]
            
            ZStack {
                if store.state.currentProject?.currentStage == .generalView {
                    ZStack{
                        FourthStageView(circleSize: .constant(circleSize))
                            .scaleEffect(0.95)
                            .disabled(true)
                        ThirdStageView(color: .appBlue, circleSize: .constant(circleSize))
                            .scaleEffect(0.55)
                            .disabled(true)
                        SecondStageView(color: .appPurple, circleSize: .constant(circleSize))
                            .scaleEffect(0.35)
                            .disabled(true)
                        FirstStageView(color: .appPink, circleSize: .constant(circleSize))
                            .scaleEffect(0.15)
                            .disabled(true)
                    }
                    
                } else {
                    ForEach((0..<4), id: \.self) { index in
                        stages[index].view
                            .scaleEffect(currentIndex == index ? 0.8 : 1.3)
                            .offset(x: offset(index: index, geometry: geometry, circleSize: circleSize), y: 0)
                            .disabled(store.state.currentProject?.currentStage.rawValue != index)
                    }
                }
                
                //Buttons
//                if (store.state.currentProject?.selectedWords.count ?? 0) > 0 && currentIndex == 0 || (store.state.currentProject?.selectedConcepts.count ?? 0) > 0 && currentIndex == 1 || (store.state.currentProject?.selectedVideos.count ?? 0) > 0 && currentIndex == 2  {
                    HStack {
                        
                        Spacer()
                            .frame(width: geometry.size.width - 200, height: geometry.size.height / 2)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                store.dispatch(.increaseIndex)
                                currentIndex = store.state.currentProject?.currentStage.rawValue ?? 0
//                                print(store.state.currentProject?.currentStage.rawValue as Any)
                                if store.state.currentProject?.currentStage == .generalView {
                                    store.dispatch(.show(true))
                                } else {
                                    store.dispatch(.show(false))
                                }
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

