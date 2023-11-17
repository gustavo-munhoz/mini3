//
//  Action.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import CloudKit
import SwiftUI

enum AppAction {
    // MARK: iCloud
    case checkiCloudAccountStatus
    case userRecordFetchedOrCreated(User)
    case cloudKitError(Error)
    case iCloudStatusError
    case requestUserRecord(fullName: String)
    
    // MARK: Onboarding
    case moveToProjectsOnboarding
    case moveToMotivationOnboarding
    case moveToCalendarOnboarding
    case moveToProfileOnboarding
    case finishOnboarding
    
    // MARK: Profile
    case expandProfileModal
    case setUIColor(Color)
    
    // MARK: Goals
    case createNewGoal
    case updateGoalContent(Goal, String)
    case toggleGoalCompletion(Int)
    
    // MARK: Navigation
    case navigateToView(ViewState)
    
    // MARK: Calendar
    case increaseMonth
    case decreaseMonth
    
    // MARK: Projects
    case createNewProject
    case projectCreated(Project)
    case projectSavedSuccessfully(Project)
    
    // MARK: FirstStage
    case selectWord(WordPosition)
    case showWord(WordPosition)
    case hideWord(WordPosition)
    
    // MARK: SecondStage
    case selectConcept(ConceptPosition)
    case showConcept(ConceptPosition)
    case hideConcept(ConceptPosition)
}

