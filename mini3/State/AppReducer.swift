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
        
    case .iCloudAccountAvailable:
        newState.isCloudAccountAvailable = true
        
    case .iCloudStatusError:
        newState.isCloudAccountAvailable = false
        
    // MARK: Profile
    case .expandProfileModal:
        newState.isProfileExpanded.toggle()
    
    // MARK: Goals
    case .toggleGoalCompletion(let goalID):
        if let user = newState.user {
            if let index = user.goals.firstIndex(where: { $0.id == goalID }) {
                user.goals[index].isCompleted.toggle()
            }
        }
    
    // MARK: Navigation
    case .navigateToView(let viewState):
        newState.viewState = viewState
        
    // MARK: CalendarModal
    case .increaseMonth:
        newState.currentDate = newState.calendar
            .date(byAdding: .month, value: 1, to: newState.currentDate) ?? newState.currentDate
        
    case .decreaseMonth:
        newState.currentDate = newState.calendar
            .date(byAdding: .month, value: -1, to: newState.currentDate) ?? newState.currentDate
        
    // MARK: Projects
    case .createNewProject:
        newState.user?.projects.append(Project(id: state.user?.projects.count ?? 1))
        
    default:
        break
    }
    
    return newState
}
