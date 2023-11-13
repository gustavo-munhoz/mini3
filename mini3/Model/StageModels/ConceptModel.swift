import Foundation
import AppKit
import SwiftUI
import Combine


class ConceptPositionable: Identifiable, ObservableObject, Equatable, Positionable {
    static func == (lhs: ConceptPositionable, rhs: ConceptPositionable) -> Bool {
        return lhs.id == rhs.id
    }
    let id = UUID()
    var content: String
    @Published var relativeX: Double
    @Published var relativeY: Double
    @Published var isVisible: Bool = true
    var cancellable: AnyCancellable?
    
    init(content: String, relativeX: Double, relativeY: Double) {
        self.content = content
        self.relativeX = relativeX
        self.relativeY = relativeY
    }
}
