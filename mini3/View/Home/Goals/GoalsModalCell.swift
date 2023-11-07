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
                .font(.system(size: 31))
            
            Text(goal.content)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, minHeight: geometry.size.height * 0.08)
        .background(goal.isCompleted ? .gray : .white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black, lineWidth: 1)
        }
        .onTapGesture {
            withAnimation {
                store.dispatch(.toggleGoalCompletion(goal.id))
            }
        }
    }
}
