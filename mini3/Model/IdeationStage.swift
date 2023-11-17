enum IdeationStage: Int, Codable {
    case generalThemes  = 0
    case specificThemes = 1
    case referenceLinks = 2
    case contentIdeas   = 3
    case generalView    = 4
    
    static let count = 5

    mutating func changeStage(by value: Int) {
        let newValue = (self.rawValue + value + IdeationStage.count) % IdeationStage.count
        self = IdeationStage(rawValue: newValue)!
    }
}
