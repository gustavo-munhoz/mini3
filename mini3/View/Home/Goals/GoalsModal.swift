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
                    .foregroundStyle(.black)
                
                Spacer()
                
                Button(action: {}) {
                    Text("VIEW ALL")
                        .frame(width: 134, height: 36)
                        .foregroundStyle(.black)
                        .font(.system(size: 15))
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.black, lineWidth: 1)
                }
            }
            
            MonthNavigator(currentMonth: $currentMonth)
            
            Group {
                // maybe sort list
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
            
            Spacer()
        }
        .padding(EdgeInsets(top: 40, leading: 40, bottom: 0, trailing: 40))
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black, lineWidth: 1)
        }
    }
}
