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
            .font(.system(size: fontSize))
            .foregroundColor(isSelected ? .blue : .black)
            .opacity(model.isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 1), value: model.isVisible)
            .onTapGesture {
                onSelected()
            }
    }
}

//#Preview {
//    ConceptView(model: ConceptPositionable(concept: "ola", relativeX: 0, relativeY: 0), isSelected: true, onSelected: {print()}, fontSize: 20)
//}
