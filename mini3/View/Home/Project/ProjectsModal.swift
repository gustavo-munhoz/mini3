//
//  ProjectsModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProjectsModal: View {
    @EnvironmentObject var store: AppStore
    var geometry: GeometryProxy
    private var columns: [GridItem] { [
        GridItem(.flexible(minimum: 200, maximum: geometry.size.width / 2 - 10)),
        GridItem(.flexible(minimum: 200, maximum: geometry.size.width / 2 - 10))
        ]
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Projects")
                        .font(.system(size: 39))
                        .fontWeight(.heavy)
                        .fontWidth(.expanded)
                        .foregroundColor(store.state.uiColor)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            store.dispatch(.createNewProject)
                        }
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
                
                Group {
                    if let projects = store.state.user?.projects, !projects.isEmpty {
                        ScrollView {
                            LazyVGrid(
                                columns: self.columns, spacing: 25,
                                content: {
                                    ForEach(0..<projects.count, id: \.self) { index in
                                        ProjectModalCell(
                                            geometry: geometry,
                                            project: projects[index]
                                        )
                                        .padding(.all, 4)
                                    }
                                }
                            )
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        VStack {
                            Spacer()
                            VStack(alignment: .center, spacing: 35) {
                                
                                Text("Your new journey is about to unfold!")
                                    .foregroundStyle(store.state.uiColor)
                                    .font(.system(size: 18, weight: .medium))
                                
                                Button(action: {
                                    store.dispatch(.createNewProject)
                                }) {
                                    Text("NEW PROJECT")
                                        .font(.system(size: 16, weight: .bold))
                                        .padding(.horizontal, 22)
                                        .padding(.vertical, 8)
                                        .background(store.state.uiColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        .foregroundStyle(Color.appBlack)
                                }
                                .buttonStyle(.plain)
                                
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 44)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(store.state.uiColor, lineWidth: 1)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding(40)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(store.state.uiColor, lineWidth: 1)
            }
            .allowsHitTesting(store.state.onboardingState == .projects || store.state.onboardingState == .finished)
            .opacity((store.state.onboardingState != .projects && store.state.onboardingState != .finished) ? 0.3 : 1)
            
            if store.state.onboardingState == .projects {
                ProjectOnboardingOverlayView()
                    .offset(x: geometry.size.width * 0.455, y: -geometry.size.height * 0.15)
            }
        }
    }
}
