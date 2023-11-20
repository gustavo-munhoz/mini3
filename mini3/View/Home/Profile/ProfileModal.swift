//
//  ProfileModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProfileModal: View {
    @EnvironmentObject var store: AppStore
    @State var geometry: GeometryProxy
    
    private var offsetSize: CGSize {
        CGSize(
            width: store.state.isProfileExpanded ? geometry.size.width * 0.13 : geometry.size.width * 0.16,
            height: store.state.isProfileExpanded ? geometry.size.height * 0.001 : 0.02
        )
    }
    
    let themeColors: [Color] = [.appBlue, .appPurple, .appPink, .appOrange, .appYellow]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 32) {
                HStack {
                    Image(store.state.user?.avatar ?? "Avatar1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.05)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(store.state.uiColor, lineWidth: 1)
                        }
                    
                    Button(action: {
                        withAnimation {
                            store.dispatch(.expandProfileModal)
                        }
                    }, label: {
                        Image(systemName: store.state.isProfileExpanded  ? "chevron.up" : "chevron.down")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                            .contentShape(RoundedRectangle(cornerRadius: 4))
                            .contentTransition(.symbolEffect(.replace))
                    })
                    .background(store.state.uiColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
                    
                }
                
                VStack {
                    if store.state.isProfileExpanded {
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                                .symbolEffect(.bounce, options: .speed(2), value: store.state.uiColor)
                            Text("Theme Color")
                        }
                        .foregroundStyle(store.state.uiColor)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        
                        HStack {
                            ForEach(themeColors, id: \.self) { themeColor in
                                ColorSelectionButton(
                                    color: themeColor,
                                    isSelected: store.state.uiColor == themeColor,
                                    action: {
                                        store.dispatch(.setUIColor(themeColor))
                                        store.dispatch(.updateUserPreferences(preferredColor: themeColor.description.split(separator: "\"").map(String.init).dropFirst().first!, avatar: "Avatar1"))
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 45)
                        .padding(.leading, 13)
                    }
                }
            }
            .padding(.top, 30)
            .padding([.trailing], 20)
            .frame(maxWidth: store.state.isProfileExpanded ? 300 : 185,
                   maxHeight: store.state.isProfileExpanded ? 250 : 118
            )
            .aspectRatio(contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(store.state.uiColor, lineWidth: 1)
            }
            .background(Color.appBlack)
            .opacity((store.state.onboardingState != .profile && store.state.onboardingState != .finished) ? 0.3 : 1)
            .offset(y: -70)
            
            if store.state.onboardingState == .profile {
                ProfileOnboardingOverlayView()
                    .offset(x: offsetSize.width * 1.2, y: -offsetSize.height)
            }
        }
        .offset(x: store.state.onboardingState == .profile ? -offsetSize.width : 0, y: offsetSize.height)
        .padding([.top], 70)
    }
}

struct ColorSelectionButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            ZStack {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(color)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .opacity(isSelected ? 1 : 0)
                    .symbolEffect(.bounce, value: isSelected)
            }
        })
        .frame(width: 44, height: 44)
        .buttonStyle(.plain)
    }
}
