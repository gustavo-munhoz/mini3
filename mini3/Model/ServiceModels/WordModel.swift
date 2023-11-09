import SwiftUI
import Foundation
import Combine
import AppKit

class WordPosition: Identifiable, ObservableObject, Equatable {
    static func == (lhs: WordPosition, rhs: WordPosition) -> Bool {
        return lhs.word == rhs.word
    }
    
    let id = UUID()
    let word: String
    var x: Double
    var y: Double
    @Published var isVisible: Bool = true
    var cancellable: AnyCancellable?

    init(word: String, x: Double, y: Double, appearDelay: TimeInterval = 0) {
        self.word = word
        self.x = x
        self.y = y
    }
}

struct RelatedWordView: View {
    @ObservedObject var wordPosition: WordPosition
    var isSelected: Bool
    var fontSize: CGFloat
    var onWordTapped: () -> Void

    var body: some View {
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

#Preview {
    RelatedWordView(wordPosition: WordPosition(word: "Bottle", x: 0, y: 0), isSelected: false, fontSize: 16, onWordTapped: {
        print()
    })
}
