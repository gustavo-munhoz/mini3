//
//  GoalsModalCell.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct GoalsModalCell: View {
    @EnvironmentObject var store: AppStore
    @State private var isEditing = false
    @State private var editableContent: String
    
    var geometry: GeometryProxy
    var goal: Goal
    
    init(geometry: GeometryProxy, goal: Goal) {
        self.goal = goal
        self.geometry = geometry
        _editableContent = State(initialValue: goal.content)
    }

    var body: some View {
        HStack(spacing: 25) {
            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 40))
                .contentTransition(.symbolEffect(.replace))
                
            if isEditing {
                TextField("", text: $editableContent, onCommit: {
                    withAnimation {
                        isEditing = false
                        store.dispatch(.updateGoalContent(goal, editableContent))
                    }
                })
                .font(.system(size: 16))
                .textFieldStyle(.roundedBorder)
            } else {
                Text(goal.content)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture(count: 2) {
                        withAnimation {
                            isEditing = true
                        }
                    }
            }
        }
        .padding(20)
        .foregroundStyle(goal.isCompleted ? Color.appBlack : store.state.uiColor)
        .aspectRatio(5.65, contentMode: .fill)
        .background(goal.isCompleted ? store.state.uiColor : .appBlack)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(store.state.uiColor, lineWidth: 1)
        }
        .onTapGesture {
            withAnimation {
                store.dispatch(.toggleGoalCompletion(goal.id))
            }
        }
    }
}

