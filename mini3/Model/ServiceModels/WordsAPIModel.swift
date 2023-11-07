import Foundation

struct WordsAPIResponse: Codable {
    let word: String
    let typeOf: [String]?
}
