//
//  GoalsModalCell.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct GoalsModalCell: View {
    var geometry: GeometryProxy
    var goal: Goal
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        HStack(spacing: 25) {
            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 40))
            
            Text(goal.content)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .foregroundStyle(store.state.uiColor)
        .aspectRatio(5.65, contentMode: .fill)
        .background(goal.isCompleted ? .white : .gray.opacity(0.2))
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
