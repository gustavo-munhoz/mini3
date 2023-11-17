//
//  CalendarOnboardingOverlayView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 16/11/23.
//

import SwiftUI

struct CalendarOnboardingOverlayView: View {
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
            
            Text("Use the calendar to plan your posts, schedule meetings, reserve time on your calendar and review the week's tasks.")
            
            HStack {
                Text("3 of 4")
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        store.dispatch(.moveToProfileOnboarding)
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
    CalendarOnboardingOverlayView()
}
