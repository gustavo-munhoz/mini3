import SwiftUI
import Foundation
import Combine
import AppKit

class ConceptPosition: Identifiable, ObservableObject, Equatable, Positionable, Codable {
    static func == (lhs: ConceptPosition, rhs: ConceptPosition) -> Bool {
        return lhs.id == rhs.id
    }
    let id = UUID()
    var content: String
    var relativeX: Double
    var relativeY: Double
    var isVisible: Bool = true
    var cancellable: AnyCancellable?

    init(word: String, relativeX: Double, relativeY: Double, appearDelay: TimeInterval = 0) {
        self.content = word
        self.relativeX = relativeX
        self.relativeY = relativeY
    }
    enum CodingKeys: CodingKey {
        case content, relativeX, relativeY, isVisible
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(String.self, forKey: .content)
        relativeX = try container.decode(Double.self, forKey: .relativeX)
        relativeY = try container.decode(Double.self, forKey: .relativeY)
        isVisible = try container.decode(Bool.self, forKey: .isVisible)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(relativeX, forKey: .relativeX)
        try container.encode(relativeY, forKey: .relativeY)
        try container.encode(isVisible, forKey: .isVisible)
    }
}

