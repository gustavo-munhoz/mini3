//
//  User.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI
import CloudKit

class User {
    var goals: [Goal]
    var projects: [Project]
    var preferredColor: String
    var avatar: String
    var userPreferencesRecord: CKRecord?
    
    init(goals: [Goal] = [], projects: [Project] = [], preferredColor: String = "AppPurple", avatar: String = "Avatar1") {
        self.goals = goals
        self.projects = projects
        self.preferredColor = preferredColor
        self.avatar = avatar
    }
}
