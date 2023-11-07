//
//  ProjectsModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProjectsModal: View {
    var geometry: GeometryProxy
    @State var projects: [Project]?
    
    var body: some View {
        VStack {
            HStack {
                Text("Projects")
                    .font(.system(size: 39))
                    .foregroundStyle(.black)
                
                
                Spacer()
                
                Button(action: {}) {
                    Text("VIEW ALL")
                        .frame(width: 134, height: 36)
                        .foregroundStyle(.black)
                        .font(.system(size: 15))
                }
                .frame(alignment: .trailing)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.black, lineWidth: 1)
                }
            }
            
            Group {
                if let projects = projects, !projects.isEmpty {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(minimum: 320, maximum: geometry.size.width / 2 - 10)),
                                GridItem(.flexible(minimum: 320, maximum: geometry.size.width / 2 - 10))
                            ],
                            spacing: 25,
                            content: {
                                ForEach(0..<projects.count, id: \.self) { index in
                                    ProjectModalCell(
                                        geometry: geometry,
                                        title: projects[index].name
                                    )
                                    .padding(.all, 4)
                                }
                            }
                        )

                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: geometry.size.height)
        .aspectRatio(1, contentMode: .fit)
        .padding(EdgeInsets(top: 40, leading: 40, bottom: 0, trailing: 40))
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.black, lineWidth: 1)
        }
    }
}
