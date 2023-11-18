//
//  ConceptView.swift
//  mini3
//
//  Created by André Wozniack on 10/11/23.
//

import SwiftUI

struct ConceptView: View{
    typealias Model = ConceptPosition
    @ObservedObject var model: Model
    var id = UUID()
    var isSelected: Bool
    var fontSize: CGFloat
    var onSelected: () -> Void

    var body: some View {
        Text(model.content)
            .font(.system(size: fontSize * 0.8, weight: .semibold))
            .foregroundStyle(isSelected ? Color.appBlack : Color.appPurple)
            .padding()
            .background(isSelected ? Color.appPurple : .appBlack)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.appPurple, lineWidth: 1)
            )
            .opacity(model.isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 1), value: model.isVisible)
            .onTapGesture {
                onSelected()
            }
            .frame(maxWidth: 500)
    }
}
