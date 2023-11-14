//
//  String+ext.swift
//  mini3
//
//  Created by André Wozniack on 10/11/23.
//

import Foundation


extension String {
    func capitalizedFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
