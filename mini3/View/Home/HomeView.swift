//
//  HomeView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 32) {
                VStack(spacing: 32) {
                    ProjectsModal(
                        geometry: geometry,
                        projects: store.state.user?.projects)
                    .aspectRatio(contentMode: .fill)
                }
                
                VStack(spacing: 32) {
                    ProfileModal(name: store.state.user?.fullName)
                    
                    GoalsModal(
                        geometry: geometry,
                        goals: store.state.user?.goals)
                    
                    Spacer()
                }
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStore(
            initial: AppState(
                user: User(id: "1",
                           fullName: "John Doe",
                           email: "email@email.com",
                           projects: Array(repeating: Project(id: 1, name: "Project"), count: 10)
                        )),
            reducer: appReducer,
            middlewares: [userMiddleware]))
}
