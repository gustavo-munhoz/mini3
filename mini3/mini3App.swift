//
//  mini3App.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 30/10/23.
//

import SwiftUI

@main
struct mini3App: App {
    @StateObject var store = AppStore(
        initial: AppState(),
        reducer: appReducer,
        middlewares: [userMiddleware]
    )
    
    var body: some Scene {
        WindowGroup {
            IdeationView(project: Project(id: 1))
                .onAppear {
                    store.dispatch(.checkiCloudAccountStatus)
                }
        }
        .environmentObject(store)
    }
}
