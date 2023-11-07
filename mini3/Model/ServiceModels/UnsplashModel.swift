import Foundation

// Modelo para representar uma imagem
struct UnsplashPhoto: Codable {
    let id: String
    let description: String?
    let urls: UnsplashPhotoURLs
}

// Modelo para representar os URLs das imagens
struct UnsplashPhotoURLs: Codable {
    let full: String
    let thumb: String
}

// Modelo para representar a resposta da API de pesquisa de fotos
struct UnsplashSearchResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [UnsplashPhoto]
}
