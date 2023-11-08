//
//  GoalsModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct GoalsModal: View {
    var geometry: GeometryProxy
    @State var goals: [Goal]?
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        VStack {
            HStack {
                Text("Goals")
                    .font(.system(size: 39))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Text("VIEW ALL")
                        .frame(width: 134, height: 36)
                        .foregroundStyle(.white)
                        .font(.system(size: 15))
                }
                .background(.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white, lineWidth: 1)
                }
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
                }
            }
        }
        .padding(40)
        .frame(maxWidth: geometry.size.width * 0.35 - 80)
        .aspectRatio(1.36, contentMode: .fill)
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white, lineWidth: 1)
        }
    }
}
