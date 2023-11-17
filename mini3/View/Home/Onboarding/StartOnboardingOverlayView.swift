//
//  StartOnboardingOverlayView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 16/11/23.
//

import SwiftUI

struct StartOnboardingOverlayView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .center, spacing: 48) {
            Text("Welcome to Muse")
                .font(.system(size: 39, weight: .heavy))
                .fontWidth(.expanded)
            
            Text("Discover Muse: your all-in-one content generation tool! It's innovative, user-friendly, and makes organizing and building ideas a breeze. Ready for a tour to explore its main tools?")
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
            
            Button(action: {
                withAnimation {
                    store.dispatch(.moveToProjectsOnboarding)
                }
            }) {
                Text("TAKE A QUICK TOUR")
                    .font(.system(size: 15, weight: .heavy))
                    .fontWidth(.expanded)
                    .foregroundStyle(Color.appBlack)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .contentShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            .background(store.state.uiColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(store.state.uiColor)
            }
            
            Button(action: {
                store.dispatch(.finishOnboarding)
            }) {
                Text("No, thanks!")
                    .font(.system(size: 16))
                    .underline()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 104)
        .padding(.vertical, 56)
        .frame(maxWidth: 700)
        .background(Color.appBlack)
        .aspectRatio(1.53, contentMode: .fill)
        .foregroundStyle(store.state.uiColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(store.state.uiColor)
        }
    }
}

#Preview {
    StartOnboardingOverlayView()
}
