//
//  User.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI

class User: Codable {
    var fullName: String
    var goals: [Goal]
    var projects: [Project]
    var preferredColor: String
    
    init(fullName: String, goals: [Goal] = [], projects: [Project] = [], preferredColor: String = "AppPurple") {
        self.fullName = fullName
        self.goals = goals
        self.projects = projects
        self.preferredColor = preferredColor
    }
}
