//
//  ProfileModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProfileModal: View {
    @State var name: String?
    
    var body: some View {
        HStack(spacing: 28) {
            Spacer()
            
            VStack(spacing: 4) {
                HStack {
                    Spacer()
                    
                    Button(action: {}, label: {
                        Text("􀆑")
                            .frame(width: 40, height: 31)
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                    })
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
                }
                
                Text(name ?? " - ")
                    .foregroundStyle(.black)
                    .font(.system(size: 29))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Circle()
                .frame(width: 105)
                .foregroundStyle(.black)
        }
        .padding(25)
        .frame(width: 595, height: 156)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black, lineWidth: 1)
        }
    }
}

#Preview {
    ProfileModal()
}
