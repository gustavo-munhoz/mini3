//
//  AppState.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

enum ViewState: Equatable {
    case home
    case ideation(Project)
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.ideation(let lhsProject), .ideation(let rhsProject)):
            return lhsProject.id == rhsProject.id
        default:
            return false
        }
    }
}

