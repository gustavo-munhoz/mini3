//
//  State.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI

struct AppState {
    var viewState: ViewState = .home
    var user: User? = nil
    var calendar: Calendar = Calendar.current
    var currentDate: Date = Date()
    var isHiddenText : Bool = false
    var uiColor: Color {
        if let preferredColor = user?.preferredColor {
            return Color.from(name: preferredColor)
        } else {
            return .appPurple
        }
    }
    
    var currentProject: Project?
}
