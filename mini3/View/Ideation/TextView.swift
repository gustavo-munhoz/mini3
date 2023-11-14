import SwiftUI

struct TextView: View {
    @State private var suggestionText: String = ""
    @State var color : Color
    @State var geometry : GeometryProxy
    var onSend: (String) -> Void
    var placeholder: String

    var body: some View {
            
        VStack {
            Spacer()
            HStack(spacing: 21) {
                TextField(placeholder, text: $suggestionText)
                    .font(.system(size: calculateFontSize(screenSize: geometry.size)))
                    .padding()
                    .foregroundColor(color)
                    .textFieldStyle(.plain)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .inset(by: 0.5)
                            .stroke(Color(color)))
                    .onSubmit {
                        onSend(suggestionText)
                    }

                
                Button(action: {
                    onSend(suggestionText)
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: geometry.size.width * 0.02, height: geometry.size.width * 0.02)
                        .foregroundColor(color)

                }
            }
            .buttonStyle(.plain)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .inset(by: 0.5)
                    .stroke(Color(color)))
            .frame(width: geometry.size.width * 0.35, height: geometry.size.width * 0.35)
            
            Spacer()
        }
        .frame(width: geometry.size.width * 0.2)
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
}
