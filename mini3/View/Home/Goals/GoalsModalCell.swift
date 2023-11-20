//
//  GoalsModalCell.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 03/11/23.
//

import SwiftUI

struct GoalsModalCell: View {
    @EnvironmentObject var store: AppStore
    
    @State private var isEditing = false
    @State private var editableContent: String
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var isHoveringEdit = false
    @State private var isHoveringDelete = false
    
    @State private var showContextMenu = false
    
    var geometry: GeometryProxy
    var goal: Goal
    
    init(geometry: GeometryProxy, goal: Goal) {
        self.goal = goal
        self.geometry = geometry
        _editableContent = State(initialValue: goal.content)
    }

    var body: some View {
        HStack(spacing: 25) {
            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 40))
                .contentTransition(.symbolEffect(.replace))
                
            if isEditing {
                TextField("", text: $editableContent, onCommit: {
                    withAnimation {
                        isEditing = false
                        let content = editableContent.trimmingCharacters(in: .whitespacesAndNewlines)
                        if content != "" {
                            store.dispatch(.updateGoalContent(goal, content))
                            store.dispatch(.updateGoal(goal))
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
                        .stroke(.white)
                }
                .textFieldStyle(.plain)
                .onAppear {
                    isTextFieldFocused = true
                }
            } else {
                Text(goal.content)
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
                .font(.system(size: 20, weight: .semibold))
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
                                store.dispatch(.deleteGoal(goal))
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
        .padding(20)
        .foregroundStyle(goal.isCompleted ? Color.appBlack : store.state.uiColor)
        .aspectRatio(5.65, contentMode: .fill)
        .background(goal.isCompleted ? store.state.uiColor : .appBlack)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(store.state.uiColor, lineWidth: 1)
        }
        .onTapGesture {
            withAnimation {
                store.dispatch(.toggleGoalCompletion(goal.id))
            }
            store.dispatch(.updateGoal(goal))
        }
    }
}

