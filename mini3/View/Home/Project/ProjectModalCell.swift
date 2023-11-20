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
    
    @State private var isEditing = false
    @State private var editableContent: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var isHoveringEdit = false
    @State private var isHoveringDelete = false
    
    @State private var showContextMenu = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.appBlack)
                .frame(minWidth: 126, minHeight: 62.5)
                .onTapGesture {
                    store.dispatch(.navigateToView(.ideation(project)))
                }
            
            
            HStack {
                if isEditing {
                    TextField("", text: $editableContent, onCommit: {
                        withAnimation {
                            isEditing = false
                            let content = editableContent.trimmingCharacters(in: .whitespacesAndNewlines)
                            if content != "" {
                                store.dispatch(.updateProjectTitle(project, editableContent))
                                store.dispatch(.updateProject(project))
                            }
                        }
                    })
                    .padding(4)
                    .focused($isTextFieldFocused)
                    .frame(minWidth: 126, maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 20, weight: .semibold))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.appBlack)
                    }
                    .textFieldStyle(.plain)
                    .onAppear {
                        isTextFieldFocused = true
                    }
                } else {
                    Text(project.name)
                        .font(.system(size: 20, weight: .semibold))
                        .frame(minWidth: 126, maxWidth: .infinity, minHeight: 12.5, alignment: .leading)
                        .onTapGesture(count: 2) {
                            withAnimation {
                                isEditing = true
                            }
                        }
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .popover(isPresented: $showContextMenu) {
                        ZStack {
                            Color.appBlack
                                .scaleEffect(1.5)
                            
                            VStack {
                                Button {
                                    isEditing = true
                                    showContextMenu = false
                                } label: {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Rename")
                                        Spacer()
                                    }
                                    .padding(8)
                                    .padding(.trailing, 24)
                                    .background(isHoveringEdit ? store.state.uiColor : .appBlack)
                                    .foregroundStyle(isHoveringEdit ? Color.appBlack : store.state.uiColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .frame(maxWidth: .infinity)
                                }
                                .onHover(perform: { hovering in
                                    isHoveringEdit = hovering
                                })
                                
                                Divider()
                                    .foregroundStyle(store.state.uiColor)
                                
                                Button {
                                    store.dispatch(.deleteProject(project))
                                    showContextMenu = false
                                } label: {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                        Spacer()
                                    }
                                    .padding(8)
                                    .padding(.trailing, 24)
                                    .background(isHoveringDelete ? store.state.uiColor : .appBlack)
                                    .foregroundStyle(isHoveringDelete ? Color.appBlack : store.state.uiColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .frame(maxWidth: .infinity)
                                    
                                }.onHover(perform: { hovering in
                                    isHoveringDelete = hovering
                                })
                                
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .padding(12)
                            
                            .buttonStyle(.plain)
                        }
                    }
                    .imageScale(.large)
                    .frame(width: 50, height: 35)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.showContextMenu = true
                    }
                    .symbolEffect(.bounce, options: .speed(2), value: showContextMenu)
            }
            .padding(.top, 12)
            .foregroundStyle(Color.appBlack)
            .font(.system(size: 20))
            
        }
        .aspectRatio(1.63, contentMode: .fill)
        .padding(25)
        .background(store.state.uiColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
//        .onAppear {
//            isEditing = true
//            isTextFieldFocused = true
//            editableContent = "New Project"
//        }
    }
}
