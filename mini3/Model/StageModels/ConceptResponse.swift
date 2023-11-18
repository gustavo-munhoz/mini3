//
//  ConceptResponse.swift
//  mini3
//
//  Created by André Wozniack on 13/11/23.
//

import Foundation


struct ConceptsResponse: Codable {
    let concepts: [String]
}

struct IdeaResponse: Codable {
    var idea: String
    var explain: String
}

