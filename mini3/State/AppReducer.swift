//
//  Reducer.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI

typealias Reducer<State, Action> = (State, Action) -> State

let appReducer: Reducer<AppState, AppAction> = { state, action in
    var newState = state
    
    switch action {
        
    // MARK: iCloud
    case .userRecordFetchedOrCreated(let user):
        newState.user = user
        
    // MARK: Goals
    case .toggleGoalCompletion(let goalID):
        if let user = newState.user {
            if let index = user.goals.firstIndex(where: { $0.id == goalID }) {
                user.goals[index].isCompleted.toggle()
            }
        }
    
    // MARK: Navigation
    case .navigateToView(let viewState):
        switch viewState {
        case .ideation(let project):
            newState.currentProject = project
            newState.viewState = viewState
        default:
            newState.viewState = viewState
        }
        
    // MARK: CalendarModal
    case .increaseMonth:
        newState.currentDate = newState.calendar
            .date(byAdding: .month, value: 1, to: newState.currentDate) ?? newState.currentDate
        
    case .decreaseMonth:
        newState.currentDate = newState.calendar
            .date(byAdding: .month, value: -1, to: newState.currentDate) ?? newState.currentDate
        
    // MARK: Projects
    case .createNewProject:
        if let user = newState.user {
            user.projects.append(Project(id: user.projects.count + 1))
        }
        
    // MARK: First Stage
    case .selectWord(let wordPosition):
        guard let project = newState.currentProject else { break }
        if project.selectedWords.contains(wordPosition) {
            // Deselecionar a palavra
            newState.currentProject?.selectedWords.removeAll { $0 == wordPosition }
        } else {
            // Selecionar a palavra
            newState.currentProject?.selectedWords.append(wordPosition)
        }
        
    case .showWord(let wordPosition):
        state.currentProject?.appearingWords.append(wordPosition)
        
    case .hideWord(let wordPosition):
        newState.currentProject?.appearingWords.removeAll { $0.id == wordPosition.id }

    default:
        break
    }
    
    return newState
}
