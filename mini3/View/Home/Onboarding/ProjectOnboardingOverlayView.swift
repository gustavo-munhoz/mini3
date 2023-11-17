//
//  ProjectOnboardingOverlayView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 16/11/23.
//

import SwiftUI

struct ProjectOnboardingOverlayView: View {
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
            
            Text("Get started with a project idea. With MUSE, you'll get some idea suggestions for any content platform, so you can worry less about formality and more about your community!")
            
            HStack(spacing: 12) {
                Text("Click")
                
                Image(systemName: "plus")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appBlack)
                    .frame(width: 46, height: 36)
                    .background(store.state.uiColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text("to create a new project")
            }
            
            Text("It's easy to create a new idea: just start with a word, choose your preferences, and select the suggestions that best fit your needs. After that, the production panel will help you structure your production!")
            
            HStack {
                Text("1 of 4")
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        store.dispatch(.moveToMotivationOnboarding)
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
        .padding(.horizontal, 38)
        .padding(.vertical, 40)
        .frame(maxWidth: 574)
        .aspectRatio(1.13, contentMode: .fill)
        .background(
            Image("top_left_arrow_onboarding_\(store.state.uiColor.description.split(separator: "\"").map(String.init)[1])")
                .resizable()
        )
    }
}

#Preview {
    ProjectOnboardingOverlayView()
}
