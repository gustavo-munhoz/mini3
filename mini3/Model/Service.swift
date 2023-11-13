import Foundation

protocol Service {
    associatedtype FetchContent
    associatedtype FetchType
    
    var baseURL: String { get }
    func fetch(using fetchType: FetchType, completion: @escaping (Result<FetchContent, Error>) -> Void)
}

struct FetchRequest<T> {
    var requestData: T
}
