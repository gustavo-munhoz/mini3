//
//  ContentView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 09/11/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        ZStack {
            HStack {
                LeftTabBarView()
                Spacer()
            }
            .hidden(store.state.viewState == .home)
            .zIndex(10)
            
            if store.state.viewState == .home {
                HomeView()
                    .frame(minWidth: 800, maxWidth: .infinity, minHeight: 450, maxHeight: .infinity)
            }

            if case .ideation(let project) = store.state.viewState {
                IdeationView(project: project)
                    .frame(minWidth: 800, maxWidth: .infinity, minHeight: 450, maxHeight: .infinity)
            }
        }
        .background(Color.appBlack)
        .animation(.easeInOut(duration: 0.15), value: store.state.viewState)
    }
}
