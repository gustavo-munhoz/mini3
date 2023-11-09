//
//  HomeView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    
    // TODO: CONTENT VIEW
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 40) {
                ProjectsModal(
                    geometry: geometry,
                    projects: store.state.user?.projects)
                
                VStack(spacing: 40) {
                    // ProfileModal(name: store.state.user?.fullName)
                    
                    GoalsModal(
                        geometry: geometry,
                        goals: store.state.user?.goals)
                    
                    CalendarModal(geometry: geometry)
                }
                .frame(maxWidth: geometry.size.width * 0.35 - 80, maxHeight: geometry.size.height - 80)
            }
            .padding(40)
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
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
