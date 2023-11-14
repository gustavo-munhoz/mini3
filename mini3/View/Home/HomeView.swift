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
                ZStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            ProfileModal()
                            Spacer()
                        }
                        Spacer()
                    }.zIndex(100)
                    
                    VStack (alignment: .leading, spacing: 40) {
                        Spacer()
                            .frame(width: 185, height: 118)
                        
                        ProjectsModal(geometry: geometry)
                    }
                }
                
                VStack(spacing: 40) {
                    
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
