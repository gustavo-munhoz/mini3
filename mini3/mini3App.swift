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
        middlewares: [userMiddleware, cloudKitMiddleware]
    )
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .aspectRatio(16/9, contentMode: .fit)
                .frame(minWidth: 1600, minHeight: 900)
                .onAppear {
                    store.dispatch(.checkiCloudAccountStatus)
                }
        }
        .environmentObject(store)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isOpaque = false
            window.backgroundColor = NSColor(resource: .appBlack)
        }
    }
}
