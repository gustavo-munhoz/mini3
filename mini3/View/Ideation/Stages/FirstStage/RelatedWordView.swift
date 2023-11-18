import Foundation
import SwiftUI
import Combine


struct RelatedWordView: View{
    typealias Model = WordPosition
    @ObservedObject var model: WordPosition
    var isSelected: Bool
    var fontSize: CGFloat
    var onSelected: () -> Void

    var body: some View {
        ZStack{
            Text(model.content)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundStyle(isSelected ? Color.appBlack : Color.appPink)
                .background(isSelected ? Color.appPink : Color.appBlack)
                .opacity(model.isVisible ? 1 : 0)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.appPink)
                        .opacity(model.isVisible ? 1 : 0)
                }
                .animation(.easeInOut(duration: 1), value: model.isVisible)
                .onTapGesture {
                    onSelected()
                }
        }
            
    }
}
#Preview {
    GeometryReader{ geometry in
        RelatedWordView(model: WordPosition(word: "test", relativeX: 0, relativeY: 20), isSelected: false, fontSize: 16, onSelected: {
            print()
        })
    }
}
