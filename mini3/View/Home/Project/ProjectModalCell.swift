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
                .fill(.gray)
                .frame(minWidth: 126, minHeight: 62.5)
            
            Text(project.name)
                .foregroundStyle(.white)
                .font(.system(size: 12))
                .frame(minWidth: 126, maxWidth: .infinity, minHeight: 12.5, alignment: .leading)
            
        }
        .aspectRatio(1.63, contentMode: .fill)
        .padding(25)
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white, lineWidth: 1)
        }
        .onTapGesture {
            store.dispatch(.navigateToView(.ideation(project)))
        }
    }
}
