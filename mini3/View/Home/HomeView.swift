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
            ZStack {
                HStack(spacing: 40) {
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack(alignment: .top) {
                                ProfileModal(geometry: geometry)
                                    .padding([.top, .leading], store.state.onboardingState == .profile ? -70 : 0)
                                    .offset(x: store.state.onboardingState == .profile ? geometry.size.width * 0.158 : 0)
                                    .zIndex(10)
                                
                                Spacer()
                                
                                Image("home_card")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 120, alignment: .trailing)
                                    .opacity((store.state.onboardingState != .finished) ? 0.3 : 1)
                            }
                            Spacer()
                        }.zIndex(5)
                        
                        VStack (alignment: .leading, spacing: 40) {
                            Spacer()
                                .frame(width: 185, height: 118)
                            
                            ProjectsModal(geometry: geometry)
                        }
                    }
                    .zIndex(store.state.onboardingState == .projects ? 2 : 1)
                    
                    VStack(spacing: 40) {
                        
                        GoalsModal(geometry: geometry)
                            
                        CalendarModal(geometry: geometry)
                    }
                    .zIndex(store.state.onboardingState == .motivation ? 2 : 1)
                    .frame(maxWidth: geometry.size.width * 0.35 - 80, maxHeight: geometry.size.height - 80)
                }
                .padding(40)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                .disabled(store.state.onboardingState == .started)
                
                if store.state.onboardingState == .started {
                    StartOnboardingOverlayView()
                }
            }
        }
    }
}
