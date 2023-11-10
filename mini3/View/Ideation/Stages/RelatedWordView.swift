import Foundation
import SwiftUI
import Combine


struct RelatedWordView: View {
    @ObservedObject var wordPosition: WordPosition
    var isSelected: Bool
    var fontSize: CGFloat
    var onWordTapped: () -> Void
    var rect : CGRect

    var body: some View {
        ZStack{
            Rectangle().frame(width: rect.width, height: rect.height)
            Text(wordPosition.word)
                .font(.system(size: fontSize))
                .foregroundColor(isSelected ? .blue : .black)
                .opacity(wordPosition.isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: wordPosition.isVisible)
                .onTapGesture {
                    onWordTapped()
                }
        }
            
    }
}

#Preview {
    GeometryReader{ geometry in
        RelatedWordView(wordPosition: WordPosition(word: "test", relativeX: 0, relativeY: 20), isSelected: false, fontSize: 16, onWordTapped: {
            print()
        }, rect: CGRect(x: 0, y: 20, width: 200, height: 200))
    }
}
