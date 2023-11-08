import Foundation

class YoutubeService {
    
    static let shared = YoutubeService()
    private let baseURL = "https://www.googleapis.com/youtube/v3/search"
    private let baseURLvideo = "https://www.youtube.com/watch?v="
    
    private init() {}

    func searchVideos(query: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        var urlComponents = URLComponents(string: baseURL)
        let queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "key", value: Secrets.YT_API_KEY),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "3")
        ]
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
             if let error = error {
                 completion(.failure(error))
                 return
             }
             
             guard let data = data else {
                 completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados inválidos"])))
                 return
             }
             
             do {
                 let decoder = JSONDecoder()
                 let response = try decoder.decode(YouTubeResponse.self, from: data)
                 completion(.success(response.items))
             } catch {
                 completion(.failure(error))
             }
         }
         task.resume()
    }
    
    func getVideoFromId(_ video: Item) -> URL{
        return URL(string: baseURLvideo+video.id.videoId)!
    }
}
