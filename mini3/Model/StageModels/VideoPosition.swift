import SwiftUI
import Foundation
import Combine
import AppKit

class VideoPosition: Identifiable, ObservableObject, Equatable, Positionable, Codable{
    static func == (lhs: VideoPosition, rhs: VideoPosition) -> Bool {
        lhs.videoURL == rhs.videoURL
    }
    
    var id = UUID()
    let title: String
    let thumbnailURL: String
    var videoURL: URL
    var relativeX : Double = 0.0
    var relativeY : Double = 0.0
    var isVisible: Bool = true
    var cancellable: AnyCancellable?
    
    init(title: String, thumbnailURL: String, videoURL: URL) {
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.videoURL = videoURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case thumbnailURL
        case videoURL
        case relativeX
        case relativeY
        case isVisible
    }
    
}

extension Item {
    func toSimpleVideo() -> VideoPosition {
        return VideoPosition(
            title: snippet.title,
            thumbnailURL: snippet.thumbnails.high.url,
            videoURL: URL(string: "https://www.youtube.com/watch?v=\(id.videoId)")!
        )
    }
}
