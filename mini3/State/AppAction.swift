//
//  Action.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import CloudKit

enum AppAction {
    
    // MARK: iCloud
    case checkiCloudAccountStatus
    case fetchOrCreateUserRecord(String)
    case userRecordFetchedOrCreated(User)
    case cloudKitError(Error)
    case iCloudAccountAvailable
    case iCloudStatusError
    
    // MARK: Goals
    case toggleGoalCompletion(Int)
}

