//
//  ConceptView.swift
//  mini3
//
//  Created by André Wozniack on 10/11/23.
//

import SwiftUI

struct ConceptView: View, ViewRepresentable {
    typealias Model = ConceptPosition
    @ObservedObject var model: Model
    var isSelected: Bool
    var fontSize: CGFloat
    var onSelected: () -> Void

    var body: some View {
        Text(model.content)
            .font(.system(size: fontSize * 0.5))
            .foregroundColor(isSelected ? .white : .appPurple) // Cor do texto alterna com base no estado isSelected
            .padding()
            .background(isSelected ? Color.appPurple : .clear) // Cor de fundo alterna com base no estado isSelected
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.clear : Color.appPurple, lineWidth: 2) // A cor do contorno alterna com base no estado isSelected
            )
            .opacity(model.isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 1), value: model.isVisible)
            .onTapGesture {
                onSelected()
            }
            .frame(maxWidth: 400)
    }
}
