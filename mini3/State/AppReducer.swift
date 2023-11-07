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
    case .userRecordFetchedOrCreated(let user):
        newState.user? = user
        
    case .iCloudAccountAvailable:
        newState.isCloudAccountAvailable = true
        
    case .iCloudStatusError:
        newState.isCloudAccountAvailable = false
        
    case .toggleGoalCompletion(let goalID):
        if let user = newState.user {
            if let index = user.goals.firstIndex(where: { $0.id == goalID }) {
                user.goals[index].isCompleted.toggle()
            }
        }
    
    default:
        break
    }
    
    return newState
}
