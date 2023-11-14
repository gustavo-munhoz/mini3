//
//  ProjectsModal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import SwiftUI

struct ProjectsModal: View {
    @EnvironmentObject var store: AppStore
    var geometry: GeometryProxy
    private var columns: [GridItem] { [
        GridItem(.flexible(minimum: 200, maximum: geometry.size.width / 2 - 10)),
        GridItem(.flexible(minimum: 200, maximum: geometry.size.width / 2 - 10))
        ]
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Projects")
                    .font(.system(size: 39))
                    .fontWeight(.heavy)
                    .fontWidth(.expanded)
                    .foregroundColor(store.state.uiColor)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        store.dispatch(.createNewProject)
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appBlack)
                        .frame(width: 46, height: 36)
                        .background(store.state.uiColor)
                }
                .buttonStyle(.plain)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Group {
                if let projects = store.state.user?.projects, !projects.isEmpty {
                    ScrollView {
                        LazyVGrid(
                            columns: self.columns, spacing: 25,
                            content: {
                                ForEach(0..<projects.count, id: \.self) { index in
                                    ProjectModalCell(
                                        geometry: geometry,
                                        project: projects[index]
                                    )
                                    .padding(.all, 4)
                                }
                            }
                        )
                    }
                    .scrollIndicators(.hidden)
                } else {
                    Spacer()
                }
            }
        }
        .padding(40)
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(store.state.uiColor, lineWidth: 1)
        }
    }
}
