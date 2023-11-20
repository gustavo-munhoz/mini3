import SwiftUI

struct IdeaView: View {
    
    @EnvironmentObject var store: AppStore
    
    var model: IdeaPosition
    @State var isSelected: Bool
    @State var fontSize: CGFloat
    var onSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(model.idea)")
                .font(.system(size: fontSize * 0.6, weight: .bold))
                .padding()
                .frame(width: 450)
                .foregroundColor(isSelected ? .appYellow : .appBlack)
                .background(isSelected ? Color.appBlack : Color.appYellow)
                .padding(.top, 0)
            
            Text(model.explanation)
                .font(.system(size: fontSize * 0.45, weight: .medium))
                .padding()
                .foregroundColor(isSelected ? .appBlack : .appYellow)
                .frame(width: 450)
            Spacer()
            
        }
        .frame(width: 450, height: 198)
        .opacity(model.isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 1), value: model.isVisible)

        .background(isSelected ? Color.appYellow : Color.appBlack)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .inset(by: 0.5)
                .stroke(Color.appYellow, lineWidth: 1)
            
        )
        .onTapGesture {
            onSelected()
            withAnimation {
                self.model.isVisible.toggle()
                print("is visible \(model.isVisible)")
                store.dispatch(.selectIdea(self.model))
                self.isSelected.toggle()
                print("is Selectd \(isSelected)")
            }
        }
    }
    
}

#Preview {
    IdeaView(model: IdeaPosition(idea: "Teste", explanation: "Music, a universal language that transcends borders and connects people across cultures, has always been a powerful medium for expression and creativity. As the world continues to evolve, so does the way we..", relativeX: 0, relativeY: 0), isSelected: true, fontSize: 16) {
        print("sla")
    }
}

