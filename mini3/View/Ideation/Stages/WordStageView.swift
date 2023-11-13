//
//  WordStageView.swift
//  mini3
//
//  Created by André Wozniack on 10/11/23.
//

import SwiftUI

struct WordStageView: View {
    @Binding var circleSize: CGFloat
    @State var color: Color
    @ObservedObject var sharedViewModel: SharedViewModel

    var body: some View {
        StageView<WordPosition, WordsService, RelatedWordView>(
            color: color,
            circleSize: $circleSize, sharedViewModel: sharedViewModel,
            service: WordsService.shared,
            onSend: { text in
                WordsService.shared.fetchRelatedWords(word: text) { result in
                    // Processa o resultado...
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let words):
                            let newViews = words.map { WordPosition(word: $0, relativeX: 0.5, relativeY: 0.5) }
                            print(words)
                            sharedViewModel.stageContent = newViews
                        case .failure(let error):
                           print(error)
                        }
                    }
                }
            }

        )
    }
}


//#Preview {
//    WordStageView()
//}
