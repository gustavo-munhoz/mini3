//
//  LeftTabBarView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 13/11/23.
//

import SwiftUI

struct LeftTabBarView: View {
    @EnvironmentObject var store: AppStore
    
    @State var didTapHome: Bool = false
    @State var didTapIdea: Bool = false
    @State var didTapStructure: Bool = false
    @State var didTapExhibit: Bool = false
    
    private var isHomeView: Bool {
        if case .home = store.state.viewState {
            return true
        }
        return false
    }
    
    private var isIdeationView: Bool {
        if case .ideation(_) = store.state.viewState {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Spacer()
            
            Button(action: {
                didTapHome.toggle()
                
                store.dispatch(.navigateToView(.home))
            }, label: {
                Image(systemName: "flame")
                    .foregroundStyle(isHomeView ? .appBlack : store.state.uiColor)
                    .font(.system(size: 32))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(isHomeView ? store.state.uiColor : .appBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .symbolEffect(.bounce, options: .speed(2), value: didTapHome)
            })
            .buttonStyle(.plain)
            
            Button(action: {
                didTapIdea.toggle()
                if !isIdeationView {
                    store.dispatch(.navigateToView(.ideation(store.state.currentProject!)))
                }
            }, label: {
                Image(systemName: "sparkles")
                    .foregroundStyle(isIdeationView ? .appBlack : store.state.uiColor)
                    .font(.system(size: 32))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(isIdeationView ? store.state.uiColor : .appBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .symbolEffect(.bounce, options: .speed(2), value: didTapIdea)
            })
            .buttonStyle(.plain)
            
            Button(action: {
                didTapStructure.toggle()
            }, label: {
                Image(systemName: "doc.text")
                    .foregroundStyle(.gray)
                    .font(.system(size: 32))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .symbolEffect(.bounce, options: .speed(2), value: didTapStructure)
            })
            .buttonStyle(.plain)
            
            Button(action: {
                didTapExhibit.toggle()
            }, label: {
                Image(systemName: "tray.and.arrow.down")
                    .foregroundStyle(.gray)
                    .font(.system(size: 32))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .symbolEffect(.bounce, options: .speed(2), value: didTapExhibit)
            })
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, 21)
        .border(width: 1, edges: [.trailing], color: store.state.uiColor)
        .background(Color.appBlack)
    }
}
