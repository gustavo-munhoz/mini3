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
        
    // MARK:
    case.show(let isHidden):
        if isHidden{
            newState.isHiddenText = true
        } else {
            newState.isHiddenText = false
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
        newState.currentProject?.appearingWords.append(wordPosition)
        
    case .hideWord(let wordPosition):
        newState.currentProject?.appearingWords.removeAll { $0.id == wordPosition.id }
        
        
    // MARK: Second Stage
    case .selectConcept(let conceptPosition):
        guard let project = newState.currentProject else { break }
        if project.selectedConcepts.contains(conceptPosition) {
            newState.currentProject?.selectedConcepts.removeAll { $0 == conceptPosition }
        } else {
            newState.currentProject?.selectedConcepts.append(conceptPosition)
        }
        
    case .showConcept(let conceptPosition):
        newState.currentProject?.appearingConcepts.append(conceptPosition)
        
    case .hideConcept(let conceptPosition):
        if !conceptPosition.isVisible{
            newState.currentProject?.appearingConcepts.removeAll { $0.id == conceptPosition.id }
        }
        
        
        
    // MARK: Third Stage
    case .selectVideo(let videoPosition):
        guard let project = newState.currentProject else { break }
        if project.selectedVideos.contains(videoPosition) {
            newState.currentProject?.selectedVideos.removeAll { $0 == videoPosition }
        } else {
            newState.currentProject?.selectedVideos.append(videoPosition)
        }
        
    case .showVideo(let videoPosition):
        newState.currentProject?.appearingVideos.append(videoPosition)
        
    case .hideVideo(let videoPosition):
        newState.currentProject?.appearingVideos.removeAll { $0.id == videoPosition.id }

    default:
        break
    }
    
    return newState
}
