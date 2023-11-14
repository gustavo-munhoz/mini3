//
//  ProfileModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProfileModal: View {
    @EnvironmentObject var store: AppStore
    @State var name: String?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 32) {
            HStack (){
                
                Image("Profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88)
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
                        .frame(width: 40, height: 31)
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                })
                .buttonStyle(.plain)
                .background(store.state.uiColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
            }
            
            Group {
                if store.state.isProfileExpanded {
                    Text("Theme Color")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .foregroundStyle(store.state.uiColor)
                    
                    HStack {
                        Button(action: {}, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.appBlue)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .opacity(store.state.uiColor == .appBlue ? 1 : 0)
                            }
                        })
                        .frame(width: 44, height: 44)
                        .buttonStyle(.plain)
                        
                        Button(action: {}, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.appPurple)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .opacity(store.state.uiColor == .appPurple ? 1 : 0)
                            }
                        })
                        .frame(width: 44, height: 44)
                        .buttonStyle(.plain)
                        
                        Button(action: {}, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.appPink)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .opacity(store.state.uiColor == .appPink ? 1 : 0)
                            }
                        })
                        .frame(width: 44, height: 44)
                        .buttonStyle(.plain)
                        
                        Button(action: {}, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.appOrange)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .opacity(store.state.uiColor == .appOrange ? 1 : 0)
                            }
                        })
                        .frame(width: 44, height: 44)
                        .buttonStyle(.plain)
                        
                        Button(action: {}, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.appYellow)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .opacity(store.state.uiColor == .appYellow ? 1 : 0)
                            }
                        })
                        .frame(width: 44, height: 44)
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(width: store.state.isProfileExpanded ? 300 : 185, height: store.state.isProfileExpanded ? 250 : 118)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(store.state.uiColor, lineWidth: 1)
        }
        .background(Color.appBlack)
    }
}
