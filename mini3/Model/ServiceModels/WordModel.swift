import SwiftUI
import Foundation
import Combine
import AppKit


class WordPosition: Identifiable, ObservableObject, Equatable {
    static func == (lhs: WordPosition, rhs: WordPosition) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id = UUID()
    let word: String
    @Published var relativeX: Double
    @Published var relativeY: Double
    @Published var isVisible: Bool = true
    var cancellable: AnyCancellable?

    init(word: String, relativeX: Double, relativeY: Double, appearDelay: TimeInterval = 0) {
        self.word = word
        self.relativeX = relativeX
        self.relativeY = relativeY
    }
}
