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
    case updateUserPreferences(preferredColor: String, avatar: String)
    case userPreferencesUpdatedSuccessfully
    
    // MARK: Goals
    case createNewGoal(String)
    case updateGoalContent(Goal, String)
    case toggleGoalCompletion(Int)
    case deleteGoal(Goal)
    case goalCreated(Goal)
    case updateGoal(Goal)
    case goalCreatedSuccessfully(Goal)
    case goalUpdatedSuccessfully(Goal)
    
    // MARK: Navigation
    case navigateToView(ViewState)
    
    // MARK: Calendar
    case increaseMonth
    case decreaseMonth
    
    // MARK: Projects
    case createNewProject
    case updateProjectTitle(Project, String)
    case deleteProject(Project)
    case projectCreated(Project)
    case updateProject(Project)
    case projectSavedSuccessfully(Project)
    case projectUpdatedSuccessfully(Project)
    case increaseIndex
    case decreaseIndex

    
    // MARK: Text View
    case show(Bool)
    
    // MARK: FirstStage
    case selectWord(WordPosition)
    case showWord(WordPosition)
    case hideWord(WordPosition)
    
    // MARK: SecondStage
    case selectConcept(ConceptPosition)
    case showConcept(ConceptPosition)
    case hideConcept(ConceptPosition)
    
    // MARK: ThirdStage
    case selectVideo(VideoPosition)
    case showVideo(VideoPosition)
    case hideVideo(VideoPosition)
    
    // MARK: FourthStage
    case selectIdea(IdeaPosition)
    case showIdea(IdeaPosition)
    case hideIdea(IdeaPosition)
    
}

