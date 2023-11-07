struct YouTubeResponse: Codable {
    let kind: String
    let etag: String
    let nextPageToken: String?
    let regionCode: String
    let pageInfo: PageInfo
    let items: [Item]
}

struct PageInfo: Codable {
    let totalResults: Int
    let resultsPerPage: Int
}

struct Item: Codable {
    let kind: String
    let etag: String
    let id: VideoID
    let snippet: Snippet
}

struct VideoID: Codable {
    let kind: String
    let videoId: String
}

struct Snippet: Codable {
    let publishedAt: String
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnails
    let channelTitle: String
    let liveBroadcastContent: String
}

struct Thumbnails: Codable {
    let `default`: Thumbnail
    let medium: Thumbnail
    let high: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
    let width: Int
    let height: Int
}
