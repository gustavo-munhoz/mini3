import Foundation

class GPTService {
    
    static let shared = GPTService()
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    func chatGPT(messages: [Message], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        // Cabeçalhos da requisição
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.GPT_API_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Conversão da lista de mensagens para o formato necessário
        let messageDicts = messages.map { ["role": $0.role, "content": $0.content] }
        
        // Corpo da requisição
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messageDicts
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        // Fazendo a requisição
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseObj = try decoder.decode(OpenAIResponse.self, from: data)
                guard let messageContent = responseObj.choices.first?.message.content else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao extrair conteúdo da resposta"])))
                    return
                }
                completion(.success(messageContent))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
