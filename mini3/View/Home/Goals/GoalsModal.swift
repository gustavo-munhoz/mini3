//
//  GoalsModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct GoalsModal: View {
    @EnvironmentObject var store: AppStore
    var geometry: GeometryProxy
    @State var goals: [Goal]?
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        VStack {
            HStack {
                Text("Motivation")
                    .font(.system(size: 39))
                    .fontWeight(.heavy)
                    .fontWidth(.expanded)
                    .foregroundColor(store.state.uiColor)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appBlack)
                        .frame(width: 46, height: 36)
                        .background(store.state.uiColor)
                }
                .buttonStyle(.plain)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appBlack)
                        .frame(width: 46, height: 36)
                        .background(store.state.uiColor)
                }
                .buttonStyle(.plain)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            MonthNavigator(currentMonth: $currentMonth)
            
            Group {
                if let goals = goals, !goals.isEmpty {
                    ScrollView {
                        VStack {
                            ForEach(0..<goals.count, id: \.self) { index in
                                let goalMonth = Calendar.current.component(.month, from: goals[index].creationDate)
                                if goalMonth == currentMonth {
                                    GoalsModalCell(
                                        geometry: geometry,
                                        goal: goals[index])
                                }
                            }
                        }.padding(4)
                    }
                } else {
                    Spacer()
                }
            }
        }
        .padding(40)
        .frame(maxWidth: geometry.size.width * 0.35 - 80)
        .aspectRatio(1.36, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(store.state.uiColor, lineWidth: 1)
        }
    }
}
