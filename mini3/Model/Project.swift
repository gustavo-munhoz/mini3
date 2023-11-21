//
//  Project.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import CloudKit

class Project: Codable, Identifiable {
    var id: Int
    var name: String
    var currentStage: IdeationStage
    
    var appearingWords: [WordPosition] = []
    var selectedWords: [WordPosition] = []
    
    var appearingConcepts: [ConceptPosition] = []
    var selectedConcepts: [ConceptPosition] = []
    
    var appearingVideos: [VideoPosition] = []
    var selectedVideos: [VideoPosition] = []
    
    var appearingIdeas : [IdeaPosition] = []
    var finalIdea: [IdeaPosition?]
    
    var cloudKitRecord: CKRecord?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currentStage
        case selectedWords
        case selectedConcepts
        case selectedVideos
        case finalIdea
    }
    
    init(id: Int, name: String = "New Project", currentStage: IdeationStage = .words,
         selectedWords: [WordPosition] = [], selectedConcepts: [ConceptPosition] = [],
         selectedVideos: [VideoPosition] = [], finalIdea: [IdeaPosition?] = [])
    {
        self.id = id
        self.name = name
        self.currentStage = currentStage
        self.selectedWords = selectedWords
        self.selectedConcepts = selectedConcepts
        self.selectedVideos = selectedVideos
        self.finalIdea = finalIdea
    }
}

// MARK: - CloudKit setup
extension Project {
    var record: CKRecord {
        if let existingRecord = cloudKitRecord {
            updateRecord(existingRecord)
            return existingRecord
            
        } else {
            let newRecord = CKRecord(recordType: "Project")
            updateRecord(newRecord)
            cloudKitRecord = newRecord
            return newRecord
        }
    }
    
    func updateRecord(_ record: CKRecord) {
        record["id"] = id as CKRecordValue
        record["name"] = name as CKRecordValue
        record["current_stage"] = currentStage.rawValue as CKRecordValue
        
        if !selectedWords.isEmpty {
            record["selected_words"] = try? JSONEncoder().encode(selectedWords)
        }
        
        if !selectedConcepts.isEmpty {
            record["selected_concepts"] = try? JSONEncoder().encode(selectedConcepts)
        }
        
        if !selectedVideos.isEmpty {
            record["selected_videos"] = try? JSONEncoder().encode(selectedVideos)
        }
        
        record["final_idea"] = finalIdea as CKRecordValue
        
        CloudKitService.saveUpdatedRecord(record) { result in
            switch result {
            case .success():
                print("Projeto atualizado com sucesso no CloudKit")
            case .failure(let error):
                print("Erro ao atualizar o projeto: \(error)")
            }
        }
    }
    
    convenience init?(record: CKRecord) {
        guard let id = record["id"] as? Int,
              let name = record["name"] as? String,
              let rawStage = record["current_stage"] as? Int else {
            return nil
        }

        let stage = IdeationStage(rawValue: rawStage) ?? .words
        let finalIdea = record["final_idea"] as? IdeaPosition

        let selectedWords: [WordPosition] = (record["selected_words"] as? Data).flatMap { try? JSONDecoder().decode([WordPosition].self, from: $0) } ?? []
        let selectedConcepts: [ConceptPosition] = (record["selected_concepts"] as? Data).flatMap { try? JSONDecoder().decode([ConceptPosition].self, from: $0) } ?? []
        let selectedVideos: [VideoPosition] = (record["selected_videos"] as? Data).flatMap { try? JSONDecoder().decode([VideoPosition].self, from: $0) } ?? []

        self.init(id: id, name: name, currentStage: stage, selectedWords: selectedWords, selectedConcepts: selectedConcepts, selectedVideos: selectedVideos, finalIdea: [finalIdea])
        
        self.cloudKitRecord = record
    }
}
