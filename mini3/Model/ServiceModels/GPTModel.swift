import Foundation

struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
    let index: Int
    let logprobs: LogProbs?
    let finishReason: String
}

struct Message: Codable {
    let role: String
    let content: String
}

struct LogProbs: Codable {
    let tokens: [String]?
    let tokenLogprobs: [Double]?
    let topLogprobs: [[String: Double]]?
}
