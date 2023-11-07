//
//  UnsplashService.swift
//  mini3
//
//  Created by André Wozniack on 01/11/23.
//

import Foundation

class UnsplashService {
    
    private let shared = UnsplashService()
    private let baseURL = "https://api.unsplash.com/"
    
    private init() {}
    
    
    func searchPhotos(query: String, completion: @escaping (Result<[UnsplashPhoto], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL + "search/photos") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "client_id", value: Secrets.UNSPLASH_KEY)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseObj = try decoder.decode(UnsplashSearchResponse.self, from: data)
                completion(.success(responseObj.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
