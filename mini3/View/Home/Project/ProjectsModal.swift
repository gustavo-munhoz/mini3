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
                    .foregroundStyle(.white)
                
                
                Spacer()
                
                Button(action: {}) {
                    Text("VIEW ALL")
                        .frame(width: 134, height: 36)
                        .foregroundStyle(.white)
                        .font(.system(size: 15))
                }
                .frame(alignment: .trailing)
                .background(.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white, lineWidth: 1)
                }
            }
            
            Group {
                if let projects = projects, !projects.isEmpty {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(minimum: 200, maximum: geometry.size.width / 2 - 10)),
                                GridItem(.flexible(minimum: 200, maximum: geometry.size.width / 2 - 10))
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
        .padding(40)
        .frame(maxWidth: geometry.size.width * 0.65 - 80, maxHeight: geometry.size.height - 80)
        .aspectRatio(1, contentMode: .fill)
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white, lineWidth: 1)
        }
    }
}
