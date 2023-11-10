//
//  Color+ext.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 09/11/23.
//

import SwiftUI

extension Color {
    static let appPurple = Color("AppPurple")
    static let appYellow = Color("AppYellow")
    static let appOrange = Color("AppOrange")
    static let appPink = Color("AppPink")
    static let appBlue = Color("AppBlue")
    static let appBlack = Color("AppBlack")
    
    static func from(name: String) -> Color {
        switch name {
        case "AppPurple":
            return .appPurple
            
        case "AppYellow":
            return .appYellow
            
        case "AppOrange":
            return .appOrange
            
        case "AppPink":
            return .appPink
            
        case "AppBlue":
            return .appBlue

        default:
            return .black
        }
    }
}
