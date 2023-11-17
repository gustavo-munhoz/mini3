//
//  ProfileOnboardingOverlayView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 16/11/23.
//

import SwiftUI

struct ProfileOnboardingOverlayView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        store.dispatch(.finishOnboarding)
                    }
                }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
            }
            
            Text("In your profile, you can change the theme color to a more custom one! Feel free to change it at any time!")
            
            HStack {
                Text("4 of 4")
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        store.dispatch(.finishOnboarding)
                    }
                }, label: {
                    Text("DONE")
                        .padding(8)
                        .foregroundStyle(Color.appBlack)
                        .background(store.state.uiColor)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                })
                .buttonStyle(.plain)
            }
            .font(.system(size: 16, weight: .semibold))
            .fontWidth(.expanded)
        }
        .multilineTextAlignment(.center)
        .font(.system(size: 18))
        .foregroundStyle(store.state.uiColor)
        .padding(.horizontal, 36)
        .padding(.vertical, 30)
        .frame(maxWidth: 328)
        .aspectRatio(0.89, contentMode: .fill)
        .background(
            Image("top_left_arrow_onboarding_\(store.state.uiColor.description.split(separator: "\"").map(String.init)[1])")
                .resizable()
        )
    }
}

#Preview {
    ProfileOnboardingOverlayView()
}
