import SwiftUI

struct YoutubeView: View {
    @EnvironmentObject var store: AppStore

    let video: VideoPosition
    @State var isSelected: Bool
    @State var fontSize: CGFloat
    @State var screenSize: CGSize
    var onSelected: () -> Void

    private let thumbnailSize: CGSize = CGSize(width: 120, height: 90)

    var body: some View {
        VStack(alignment: .center) {
            AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            .cornerRadius(fontSize * 0.05)

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.system(size: calculateFontSize(screenSize: screenSize) - screenSize.width * 0.12))
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .appBlack : .appBlue)
                    .lineLimit(nil)
                    .frame(maxWidth: thumbnailSize.width)
                    .padding(8)
                
                Link("Watch on YouTube", destination: video.videoURL)
                    .font(.system(size: calculateFontSize(screenSize: screenSize) - screenSize.width * 0.2))
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .padding()
        .background(isSelected ? Color.appBlue : Color.appBlack)
        .cornerRadius(fontSize * 0.05)
        .overlay(
            RoundedRectangle(cornerRadius: fontSize * 0.05)
                .inset(by: 0.5)
                .stroke(Color.appBlue, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 1), value: video.isVisible)
        .onTapGesture {
            onSelected()
            withAnimation(.easeInOut(duration: 1)) {
                self.isSelected.toggle()
                store.dispatch(.selectVideo(video))
            }
        }
        .opacity(video.isVisible ? 1 : 0)
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

#Preview {
    GeometryReader { geo in
        YoutubeView(video: VideoPosition(title: "Tate McRae, Khalid - working (Official Video)", thumbnailURL: "https://i.ytimg.com/vi/9pfPGVfMH74/hqdefault.jpg", videoURL: (URL(string: "https://www.youtube.com/watch?=9pfPGVfMH74") ?? URL(string: "https://www.youtube.com")!)), isSelected: false, fontSize: 8, screenSize: geo.size) {
            print("oskay")
        }
    }
}
