//
//  ProjectModalCell.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProjectModalCell: View {
    var geometry: GeometryProxy
    @State var title: String

    var body: some View {
        VStack {
            Rectangle()
                .fill(.gray)
                .frame(minWidth: 254, minHeight: 125)
            
            Text(title)
                .foregroundStyle(.black)
                .font(.system(size: 12))
                .frame(minWidth: 254, maxWidth: .infinity, minHeight: 25, alignment: .leading)
            
        }
        .aspectRatio(1.63, contentMode: .fill)
        .padding(25)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black, lineWidth: 1)
        }
    }
}
