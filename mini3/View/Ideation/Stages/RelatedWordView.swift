import Foundation
import SwiftUI
import Combine




struct RelatedWordView: View, ViewRepresentable {
    typealias Model = WordPosition
    @ObservedObject var model: WordPosition
    var isSelected: Bool
    var fontSize: CGFloat
    var onSelected: () -> Void

    var body: some View {
        ZStack{
            Text(model.content)
                .font(.system(size: fontSize))
                .foregroundColor(isSelected ? .blue : .black)
                .opacity(model.isVisible ? 1 : 0)
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
