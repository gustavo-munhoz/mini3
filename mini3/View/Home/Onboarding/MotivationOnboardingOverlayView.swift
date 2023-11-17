//
//  MotivationOnboardingOverlayView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 16/11/23.
//

import SwiftUI

struct MotivationOnboardingOverlayView: View {
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
            
            Text("Create your main goals, keep it up with your checklist status and remind yourself of the main motivation for content creation!")
            
            HStack {
                Text("2 of 4")
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        store.dispatch(.moveToCalendarOnboarding)
                    }
                }, label: {
                    HStack {
                        Text("NEXT")
                        Image(systemName: "chevron.right")
                    }
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
            Image("top_right_arrow_onboarding_\(store.state.uiColor.description.split(separator: "\"").map(String.init)[1])")
                .resizable()
        )
    }
}

#Preview {
    MotivationOnboardingOverlayView()
}
