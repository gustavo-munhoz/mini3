enum IdeationStage: Int, Codable {
    case words       = 0
    case concepts    = 1
    case references  = 2
    case ideas       = 3
    case generalView = 4
    
    static let count = 5

    mutating func changeStage(by value: Int) {
        let newValue = (self.rawValue + value + IdeationStage.count) % IdeationStage.count
        self = IdeationStage(rawValue: newValue)!
    }
}
