//
//  ThirdStageVIew.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 13/11/23.
//

import SwiftUI

struct ThirdStageView: View {
    @State private var mediaItems: [MediaItem] = [] // Modelo para armazenar imagens e vídeos
    @State private var selectedMedia: [MediaItem] = [] // Itens de mídia selecionados
    @State private var mediaPositions: [WordPosition] = []
    @State private var errorMessage: String?
    @State private var error: Bool = false
    @State var color: Color
    @Binding var circleSize: CGFloat

    private let youtubeService = YoutubeService.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Ellipse()
                    .foregroundColor(.black)
                    .overlay {
                        Circle()
                            .stroke(color, lineWidth: 5)
                            
                    }
                    .frame(width: circleSize, height: circleSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                ForEach(mediaItems) { mediaItem in
                    YoutubeVideoModal(model: mediaItem, isSelected: selectedMedia.contains(mediaItem)) {
                        withAnimation {
                            handleMediaSelection(mediaItem: mediaItem)
                        }
                    }
                    .position(x: mediaItem.relativeX * geometry.size.width,
                              y: mediaItem.relativeY * geometry.size.height)
                }
                
//                TextView(color: color, geometry: geometry, onSend: { text in
//                    inputWord = text
//                    let newWordPosition = generateNonOverlappingPosition(screenSize: geometry.size, word: inputWord, fontSize: calculateFontSize(screenSize: geometry.size))
//                    if !inputWord.isEmpty {
//                        selectedMedia.append(newWordPosition)
//                    }
//                    fetchRelatedWords(geometry: geometry)
//                    for i in selectedMedia {
//                        print(i.content)
//                    }
//                    inputWord = ""
//                })
//                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.01))
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }
    
    private func handleMediaSelection(mediaItem: MediaItem) {
            if let index = selectedMedia.firstIndex(where: { $0.id == mediaItem.id }) {
                selectedMedia.remove(at: index)
            } else {
                selectedMedia.append(mediaItem)
            }
        }
        
    private func fetchYouTubeVideos(query: String) {
        youtubeService.searchVideos(query: query) { result in
            switch result {
            case .success(let items):
                mediaItems = items.map { item -> MediaItem in
                    MediaItem(title: item.snippet.title, thumbnailURL: URL(string: item.snippet.thumbnails.high.url)!, relativeX: 0.5, relativeY: 0.5)
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func calculateFontSize(screenSize: CGSize) -> CGFloat {
        let baseFontSize: CGFloat = 8 // Tamanho base para a fonte
        let scaleFactor: CGFloat = 0.02 // Fator de escalonamento para ajustar o tamanho da fonte com base na tela
        
        // Use o menor entre a largura e a altura para o escalonamento para garantir que a fonte se ajuste bem em ambas as dimensões
        let scalingDimension = min(screenSize.width, screenSize.height)
        
        // Calcule o tamanho da fonte ajustado
        let adjustedFontSize = baseFontSize + (scalingDimension * scaleFactor)
        
        return adjustedFontSize
    }
    
    func randomPointInCircle(center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = CGFloat.random(in: 0..<2 * .pi)
        let randomRadius = CGFloat.random(in: 0..<radius)
        return CGPoint(
            x: center.x + randomRadius * cos(angle),
            y: center.y + randomRadius * sin(angle)
        )
    }
    
    func rectangleAroundString(at point: CGPoint, for word: String, with fontSize: CGFloat) -> CGRect {
        let estimatedWidth = CGFloat(word.count) * fontSize// Ajuste conforme a fonte
        let estimatedHeight = fontSize// Ajuste conforme a fonte
        let rect = CGRect(x: point.x - estimatedWidth / 2, y: point.y - estimatedHeight / 2, width: estimatedWidth, height: estimatedHeight)
        return rect
    }
    
    func isRectangleInsideCircle(_ rect: CGRect, inCircle center: CGPoint, radius: CGFloat) -> Bool {
        // Encontrar o ponto no retângulo mais distante do centro do círculo
        let furthestPoint = CGPoint(
            x: max(abs(rect.minX - center.x), abs(rect.maxX - center.x)),
            y: max(abs(rect.minY - center.y), abs(rect.maxY - center.y))
        )
        
        // Calcular a distância desse ponto ao centro
        let distanceToFurthestPoint = sqrt(pow(furthestPoint.x, 2) + pow(furthestPoint.y, 2))
        
        // Se a distância for menor que o raio, então o retângulo está dentro do círculo
        return distanceToFurthestPoint <= radius
    }
    
    func doRectanglesOverlap(_ rect1: CGRect, _ rect2: CGRect) -> Bool {
        print(rect1.intersects(rect2))
        return rect1.intersects(rect2)
    }
    
    func generateNonOverlappingPosition(screenSize: CGSize, word: String, fontSize: CGFloat) -> WordPosition {
        let circleCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let circleRadius = circleSize / 2
        
        // Tente encontrar uma posição não sobreposta um número limitado de vezes
        for _ in 0..<10000 {
            let randomPoint = randomPointInCircle(center: circleCenter, radius: circleRadius)
            let wordRect = rectangleAroundString(at: randomPoint, for: word, with: fontSize)
            
            // Verifique se o retângulo da palavra está dentro do círculo
            if isRectangleInsideCircle(wordRect, inCircle: circleCenter, radius: circleRadius) {
                var overlapFound = false
                
                // Verifique se o novo retângulo se sobrepõe a algum dos retângulos existentes
                for existingWordPosition in mediaPositions {
                    let existingRect = rectangleAroundString(at: CGPoint(x: existingWordPosition.relativeX * screenSize.width, y: existingWordPosition.relativeY * screenSize.height), for: existingWordPosition.content, with: fontSize)
                    if wordRect.intersects(existingRect) {
                        overlapFound = true
                        break
                    }
                }
                
                // Se não houver sobreposição, esta é uma posição válida
                if !overlapFound {
                    let relativeX = randomPoint.x / screenSize.width
                    let relativeY = randomPoint.y / screenSize.height
                    return WordPosition(word: word, relativeX: relativeX, relativeY: relativeY)
                }
            }
        }
        
        // Se todas as tentativas falharem, retorne uma posição padrão (centro, por exemplo)
        return WordPosition(word: word, relativeX: 0.5, relativeY: 0.5)
    }
    
    
}
