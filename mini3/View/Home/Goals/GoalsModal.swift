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
    
    var body: some View {
            ZStack {
                VStack {
                    header
                    MonthNavigator()
                    goalsContent
                }
                .padding(40)
                .frame(maxWidth: geometry.size.width * 0.35 - 80)
                .aspectRatio(1.36, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(store.state.uiColor, lineWidth: 1)
                }
                .opacity((store.state.onboardingState != .motivation && store.state.onboardingState != .finished) ? 0.3 : 1)
                
                if store.state.onboardingState == .motivation {
                    MotivationOnboardingOverlayView()
                        .offset(x: -geometry.size.width * 0.235, y: -geometry.size.height * 0.185)
                }
            }
        }

    private var header: some View {
        HStack {
            Text("Motivation")
                .font(.system(size: 39))
                .fontWeight(.heavy)
                .fontWidth(.expanded)
                .foregroundColor(store.state.uiColor)
            
            Spacer()
            
            Button(action: {
                store.dispatch(.createNewGoal("New Motivation"))
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appBlack)
                    .frame(width: 46, height: 36)
                    .background(store.state.uiColor)
            }
            .buttonStyle(.plain)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    private var goalsContent: some View {
        Group {
            if let goals = store.state.user?.goals, !goals.isEmpty {
                ScrollView {
                    VStack {
                        ForEach(0..<goals.count, id: \.self) { index in
                            let goalMonth = Calendar.current.component(.month, from: goals[index].date)
                            if goalMonth == store.state.calendar.component(.month, from: store.state.currentDate) {
                                GoalsModalCell(
                                    geometry: geometry,
                                    goal: goals[index])
                            }
                        }
                    }.padding(4)
                }
            } else {
                emptyGoalsView
            }
        }
    }

    private var emptyGoalsView: some View {
        VStack {
            Spacer()
                .frame(height: 24)
            
            VStack(alignment: .center, spacing: 35) {
                
                Text("Your path to success is open and ready for your goals!")
                    .foregroundStyle(store.state.uiColor)
                    .font(.system(size: 18, weight: .medium))
                
                Button(action: {
                    store.dispatch(.createNewGoal("New Motivation"))
                }) {
                    Text("NEW GOAL")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 8)
                        .background(store.state.uiColor)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .foregroundStyle(Color.appBlack)
                }
                .buttonStyle(.plain)
                
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(store.state.uiColor, lineWidth: 1)
            }
            Spacer()
        }
    }
}
