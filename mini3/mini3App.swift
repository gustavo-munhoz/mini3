//
//  mini3App.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 30/10/23.
//

import SwiftUI

@main
struct mini3App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(AppStore(
            initial: AppState(
                user: User(id: "1",
                           fullName: "Jorge",
                           email: "email@email.com",
                           goals: [
                                Goal(id: 1, content: "Goal 1"),
                                Goal(id: 2, content: "Goal 2"),
                                Goal(id: 3, content: "Goal 3"),
                                Goal(id: 4, content: "Goal 4"),
                                Goal(id: 5, content: "Goal 5")
                           ],
                           projects: Array(repeating: Project(id: 1, name: "Project"), count: 10)
                           
            )),
            reducer: appReducer,
            middlewares: [userMiddleware]
        ))
    }
}
