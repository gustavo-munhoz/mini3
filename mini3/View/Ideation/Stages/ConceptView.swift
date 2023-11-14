//
//  ConceptView.swift
//  mini3
//
//  Created by André Wozniack on 10/11/23.
//

import SwiftUI

struct ConceptView: View, ViewRepresentable {
    typealias Model = ConceptPositionable
    @ObservedObject var model: Model
    var isSelected: Bool
    var onSelected: () -> Void
    var fontSize: CGFloat

    var body: some View {
        Text(model.content)
            .font(.system(size: fontSize * 0.5))
            .foregroundColor(isSelected ? .white : .appPurple) // Cor do texto alterna com base no estado isSelected
            .padding() // Adicionar um pouco de espaço ao redor do texto
            .background(isSelected ? Color.appPurple : .clear) // Cor de fundo alterna com base no estado isSelected
            .overlay(
                RoundedRectangle(cornerRadius: 10) // Forma do contorno arredondado
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

#Preview {
    ConceptView(model: ConceptPositionable(content: "ola", relativeX: 0, relativeY: 0), isSelected: true, onSelected: {print()}, fontSize: 20)
}
