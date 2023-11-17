import SwiftUI

struct IdeaView: View {
    @EnvironmentObject var store: AppStore

    let video: VideoPosition
    @State var isSelected: Bool
    @State var fontSize: CGFloat
    @State var screenSize: CGSize
    var onSelected: () -> Void

    private let thumbnailSize: CGSize = CGSize(width: 120, height: 90)

    var body: some View {
        Text("Ola")
    }
    
    func calculateFontSize(screenSize: CGSize) -> CGFloat {
        let baseFontSize: CGFloat = 8 // Tamanho base para a fonte
        let scaleFactor: CGFloat = 0.02 // Fator de escalonamento para ajustar o tamanho da fonte com base na tela
        
        // Use o menor entre a largura e a altura para o escalonamento para garantir que a fonte se ajuste bem em ambas as dimensões
        let scalingDimension = min(screenSize.width, screenSize.height)
        
        // Calcule o tamanho da fonte ajustado
        let adjustedFontSize = baseFontSize + (scalingDimension * scaleFactor)
        
        return adjustedFontSize
    }
}

// Supondo que VideoPosition seja uma estrutura que você já tenha definido.

