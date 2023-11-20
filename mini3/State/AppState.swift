//
//  State.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI
import Foundation

struct AppState {
    var viewState: ViewState = .home
    var user: User? = nil
    var calendar: Calendar = Calendar.current
    var currentDate: Date = Date()
    var isHiddenText : Bool = false
    var inputTextEnable : Bool = true
    var isProfileExpanded: Bool = false
    var currentProject: Project?
    var uiColor: Color {
        if let preferredColor = user?.preferredColor {
            return Color.from(name: preferredColor)
        } else {
            return .appPurple
        }
    }
    
    private var _onboardingState: OnboardingState = .started

    var onboardingState: OnboardingState {
        get {
            _onboardingState
        }
        set {
            _onboardingState = newValue
            if newValue == .finished {
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.onboardingCompleted)
            }
        }
    }
    
    private struct UserDefaultsKeys {
        static let onboardingCompleted = "onboardingCompleted"
    }
    
    init() {
        let onboardingCompleted = UserDefaults.standard.bool(forKey: UserDefaultsKeys.onboardingCompleted)
        if onboardingCompleted {
            _onboardingState = .finished
        }
    }
}
