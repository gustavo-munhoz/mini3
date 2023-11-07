//
//  TimelineCellView.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct TimelineCellView: View {
    @State var content: String
    
    var body: some View {
        Text(content.uppercased())
            .foregroundStyle(.black)
            .frame(width: 136, height: 108)
            .clipShape(.rect(cornerRadius: 16))
            .border(.black, width: 1)
            .background(.white)
    }
}

#Preview {
    TimelineCellView(content: "MOTIVATE")
}
