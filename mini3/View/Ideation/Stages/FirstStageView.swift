import SwiftUI
import Combine

struct FirstStageView: View {
    @State private var inputWord: String = ""
    @State private var wordPositions: [WordPosition] = []
    @State private var selectedWords: [WordPosition] = []
    @State private var errorMessage: String?
    @State private var error : Bool = false
    @State var color : Color
    @Binding var circleSize: CGFloat
    private let wordsService = WordsService.shared

    var body: some View {
        GeometryReader { geometry in
            
            ZStack{
                Ellipse()
                    .foregroundColor(color)
                    .frame(width: circleSize, height: circleSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                TextField("Word...", text: $inputWord)
                    .font(.title)
                    .padding()
                    .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.2)
                    .background(.clear)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        
                        let newWordPosition = generateNonOverlappingPosition(screenSize: geometry.size, word: inputWord)
                        // Adiciona a nova palavra diretamente à lista de palavras selecionadas
                        if !inputWord.isEmpty {
                            selectedWords.append(newWordPosition)
                        }
                        fetchRelatedWords(geometry: geometry)
                        // Pode ser necessário lidar com a seleção de palavras apenas se você deseja alguma interação adicional
                        // handleWordSelection(wordPosition: newWordPosition)
                        for i in selectedWords {
                            print(i.word)
                        }
                        
                    }
                    .textFieldStyle(.plain)
                
                ForEach(wordPositions.filter { !selectedWords.contains($0) }) { wordPosition in
                    Text(wordPosition.word)
                        .font(.system(size: 20)) // Tamanho fixo da fonte
                        .foregroundColor(.black) // Cor da fonte
                        .opacity(wordPosition.isVisible ? 1 : 0) // Controla a opacidade
                        .animation(.easeInOut(duration: 1), value: wordPosition.isVisible) // Anima a opacidade
                        .position(x: wordPosition.x, y: wordPosition.y)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                if !selectedWords.contains(wordPosition) {
                                    withAnimation(.easeOut(duration: 1)) {
                                        wordPosition.isVisible = false
                                    }
                                }
                            }
                        }
                        .onTapGesture {
                            handleWordSelection(wordPosition: wordPosition)
                            fetchRelatedWords(with: wordPosition.word, geometry: geometry)
                            
                        }
                }
                
                ForEach(selectedWords) { wordPosition in
                    RelatedWordView(
                        wordPosition: wordPosition,
                        isSelected: true,
                        fontSize: 16,
                        onWordTapped: {
                            withAnimation(.easeInOut(duration: 1)){
                                handleWordSelection(wordPosition: wordPosition)
                            }
                        }
                    )
                    .position(x: wordPosition.x, y: wordPosition.y)
                }
            }
        }
        .alert(isPresented: $error, content: {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? "Erro desconhecido"), dismissButton: .default(Text("OK")))
        })
    }
    
    private func handleWordSelection(wordPosition: WordPosition) {
        if let index = selectedWords.firstIndex(where: { $0 == wordPosition }) {
                selectedWords.remove(at: index)
                wordPositions.removeAll { $0.id == wordPosition.id
            }
        } else {
            selectedWords.append(wordPosition)
        }
    }
    
    private func fetchRelatedWords(with word: String, geometry: GeometryProxy) {

        wordsService.fetchRelatedWords(word: word) { [self] result in // Use the 'word' parameter here
            DispatchQueue.main.async {
                switch result {
                case .success(let words):
                    var delay = 0.0
                    for word in words {
                        delay += 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeInOut(duration: 1)) {
                                let wp = generateNonOverlappingPosition(screenSize: geometry.size, word: word)
                                if !self.selectedWords.contains(wp) {
                                    self.wordPositions.append(wp)
                                    wp.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                                        .autoconnect()
                                        .sink { _ in
                                            if !self.selectedWords.contains(wp) {
                                                self.wordPositions.removeAll { $0.id == wp.id }
                                            }
                                        }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.error = true
                }
            }
        }
    }


    private func fetchRelatedWords(geometry: GeometryProxy) {
        guard !inputWord.isEmpty else {
            self.error = true
            self.errorMessage = "Por favor, insira uma palavra."
            return
        }

        wordsService.fetchRelatedWords(word: inputWord) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let words):
                    var delay = 0.0
                    for word in words {
                        delay += 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            withAnimation(.easeInOut(duration: 1)){
                                let wp = generateNonOverlappingPosition(screenSize: geometry.size, word: word)
                                if !self.selectedWords.contains(wp) {
                                    self.wordPositions.append(wp)
                                    wp.cancellable = Timer.publish(every: 8, on: .main, in: .common)
                                        .autoconnect()
                                        .sink { _ in
                                            if !self.selectedWords.contains(wp) {
                                                self.wordPositions.removeAll { $0.id == wp.id }
                                            }
                                        }
                                }
                            }
                            
                        }
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.error = true
                }
            }
        }
    }


    
    private func calculateFontSize(geometry: GeometryProxy) -> CGFloat {
        let baseFontSize: CGFloat = 16 // Comece com um tamanho base
        let scalingFactor: CGFloat = 0.1 // Defina um fator de escalonamento baseado no número de palavras
        return baseFontSize + (geometry.size.width / CGFloat(wordPositions.count) * scalingFactor)
    }
    
    private func generateNonOverlappingPosition(screenSize: CGSize, word: String) -> WordPosition {
            var newPosition: (x: Double, y: Double)
            var positionIsUnique = false
            let fontSize = screenSize.width * 0.01
            let textFieldHeight: CGFloat = 50 // A altura estimada do TextField
            let safeZone: CGFloat = 10 // Espaço adicional em torno do TextField

            repeat {
                // Gera um ângulo e raio aleatórios para posicionar a palavra dentro do círculo em porcentagem.
                let angle = Double.random(in: 0...(2 * .pi))
                let radius = Double.random(in: 0...1) * Double(circleSize / 2) // Raio como porcentagem do raio do círculo.
                newPosition.x = (cos(angle) * radius) / Double(screenSize.width) + 0.5 // Centralizado e convertido para porcentagem.
                newPosition.y = (sin(angle) * radius) / Double(screenSize.height) + 0.5 // Centralizado e convertido para porcentagem.

                if (newPosition.y * screenSize.height) > (textFieldHeight + safeZone) &&
                    (newPosition.y * screenSize.height) < (screenSize.height - (textFieldHeight + safeZone)) {
                    positionIsUnique = true
                }
                
                // Verifica se a posição não se sobrepõe com outras palavras na tela.
                positionIsUnique = !wordPositions.contains { wordPosition in
                    // Calcula a distância em porcentagem do tamanho da tela para verificar sobreposição.
                    let distance = sqrt(pow(wordPosition.x - newPosition.x, 2) + pow(wordPosition.y - newPosition.y, 2))
                    return distance < (fontSize / screenSize.width) // Distância mínima como porcentagem do tamanho da tela.
                }
            } while !positionIsUnique
            
            return WordPosition(word: word, x: newPosition.x * screenSize.width, y: newPosition.y * screenSize.height, appearDelay: Double.random(in: 1...3.5))
        }

}

#Preview {
    FirstStageView(color: .gray ,circleSize: .constant(1000))
}
