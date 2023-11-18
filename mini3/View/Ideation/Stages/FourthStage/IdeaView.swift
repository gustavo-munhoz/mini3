import SwiftUI

struct IdeaView: View {
    
    @EnvironmentObject var store: AppStore
    
    var model: IdeaPosition
    var isSelected: Bool
    var fontSize: CGFloat
    var onSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("IDEA: \(model.idea)")
                .font(.system(size: fontSize, weight: .bold))
                .padding()
                .frame(width: 500)
                .foregroundColor(.appBlack)
                .background(Color.appYellow)
                .padding(.top, 0)
            
            Text(model.explanation)
                .font(.system(size: fontSize * 0.85, weight: .medium))
                .padding()
                .foregroundColor(.appYellow)
                .frame(width: 500)
            Spacer()
            
        }
        .frame(width: 500, height: 220)
        .opacity(model.isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 1), value: model.isVisible)
        .onTapGesture {
            onSelected()
            withAnimation {
                self.model.isVisible.toggle()
//                store.dispatch()
            }
        }
        .background(Color.appBlack)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .inset(by: 0.5)
                .stroke(Color.appYellow, lineWidth: 1)
            
        )
    }
}

#Preview {
    IdeaView(model: IdeaPosition(idea: "Teste", explanation: "Music, a universal language that transcends borders and connects people across cultures, has always been a powerful medium for expression and creativity. As the world continues to evolve, so does the way we..", relativeX: 0, relativeY: 0), isSelected: false, fontSize: 16) {
        print("sla")
    }
}

