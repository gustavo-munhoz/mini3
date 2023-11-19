import SwiftUI
import Combine

class IdeaPosition: Codable, Identifiable, Equatable {
    static func == (lhs: IdeaPosition, rhs: IdeaPosition) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    var relativeX: Double
    var relativeY: Double
    var isVisible: Bool = true
    var isPositioned: Bool = false
    var cancellable: AnyCancellable?

    var idea: String
    var explanation: String

    init(idea: String, explanation: String, relativeX: Double, relativeY: Double) {
        self.idea = idea
        self.explanation = explanation
        self.relativeX = relativeX
        self.relativeY = relativeY
    }
    
    func setPosition(relativeX: Double, relativeY: Double) {
        self.relativeX = relativeX
        self.relativeY = relativeY
    }
    
    enum CodingKeys: CodingKey {
        case id, relativeX, relativeY, isVisible, idea, explanation
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        relativeX = try container.decode(Double.self, forKey: .relativeX)
        relativeY = try container.decode(Double.self, forKey: .relativeY)
        isVisible = try container.decode(Bool.self, forKey: .isVisible)
        idea = try container.decode(String.self, forKey: .idea)
        explanation = try container.decode(String.self, forKey: .explanation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(relativeX, forKey: .relativeX)
        try container.encode(relativeY, forKey: .relativeY)
        try container.encode(isVisible, forKey: .isVisible)
        try container.encode(idea, forKey: .idea)
        try container.encode(explanation, forKey: .explanation)
    }
}
