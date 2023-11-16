//
//  ProjectModalCell.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProjectModalCell: View {
    var geometry: GeometryProxy
    @State var project: Project
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.appBlack)
                .frame(minWidth: 126, minHeight: 62.5)
            
            Text(project.name)
                .foregroundStyle(Color.appBlack)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .frame(minWidth: 126, maxWidth: .infinity, minHeight: 12.5, alignment: .leading)
            
        }
        .aspectRatio(1.63, contentMode: .fill)
        .padding(25)
        .background(store.state.uiColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onTapGesture {
            store.dispatch(.navigateToView(.ideation(project)))
        }
    }
}
