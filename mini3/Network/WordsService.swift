import Foundation

final class WordsService: Service {
    
    typealias FetchContent = [String]
    typealias FetchType = String
    
    static let shared = WordsService()
    let baseURL = "https://wordsapiv1.p.rapidapi.com/words"
    
    private init() {}

    func fetch(using fetchType: String, completion: @escaping (Result<[String], Error>) -> Void) {
        fetchRelatedWords(word: fetchType, completion: completion)
    }
    
    
    func fetchRelatedWords(word: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(word)/typeOf") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(Secrets.WORDS_API_KEY, forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("wordsapiv1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                let response = try decoder.decode(WordsAPIResponse.self, from: data)
                if let typesOf = response.typeOf {
                    completion(.success(typesOf))
                } else {
                    completion(.success([]))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

