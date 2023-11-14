//
//  Project.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import CloudKit

class Project/*: Codable, Identifiable*/ {
    var id: Int
    var name: String
    var currentStage: IdeationStage
    var appearingWords: [WordPosition] = []
    var selectedWords: [WordPosition]
    var appearingConcepts: [ConceptPosition] = []
    var selectedConcepts: [ConceptPosition] = []
    var specificThemes: [String]
    var referenceLinks: [String]
    var contentIdeas: [String]
    var finalIdea: String?
    
    init(id: Int, name: String = "New Project", currentStage: IdeationStage = .generalThemes,
         selectedWords: [WordPosition] = [], specificThemes: [String] = [],
         referenceLinks: [String] = [], contentIdeas: [String] = [],
         finalIdea: String? = nil)
    {
        self.id = id
        self.name = name
        self.currentStage = currentStage
        self.selectedWords = selectedWords
        self.specificThemes = specificThemes
        self.referenceLinks = referenceLinks
        self.contentIdeas = contentIdeas
        self.finalIdea = finalIdea
    }
}

// MARK: CloudKit setup
extension Project {
    var record: CKRecord {
        let record = CKRecord(recordType: "Project")
        record["id"] = id as CKRecordValue
        record["name"] = name as CKRecordValue
        record["currentStage"] = currentStage.rawValue as CKRecordValue
        
        // Serializar selectedWords e appearingWords para JSON
        record["selectedWords"] = try? JSONEncoder().encode(selectedWords) as CKRecordValue?
        record["specificThemes"] = specificThemes as CKRecordValue
        record["referenceLinks"] = referenceLinks as CKRecordValue
        record["contentIdeas"] = contentIdeas as CKRecordValue
        record["finalIdea"] = finalIdea as CKRecordValue?
        return record
    }
    
    convenience init?(record: CKRecord) {
        guard let id = record["id"] as? Int,
              let name = record["name"] as? String,
              let rawStage = record["currentStage"] as? Int,
              let selectedWordsData = record["generalThemes"] as? Data,
              let specificThemes = record["specificThemes"] as? [String],
              let referenceLinks = record["referenceLinks"] as? [String],
              let contentIdeas = record["contentIdeas"] as? [String]
        else {
            return nil
        }
        
        let stage = IdeationStage(rawValue: rawStage) ?? .generalThemes
        let finalIdea = record["finalIdea"] as? String
        
        let selectedWords = (try? JSONDecoder().decode([WordPosition].self, from: selectedWordsData)) ?? []
        
        self.init(id: id, name: name, currentStage: stage, selectedWords: selectedWords,
                  specificThemes: specificThemes, referenceLinks: referenceLinks,
                  contentIdeas: contentIdeas, finalIdea: finalIdea)
    }
}
