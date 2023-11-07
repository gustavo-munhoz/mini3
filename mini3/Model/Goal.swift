//
//  Goal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import CloudKit

class Goal: Codable {
    var id: Int
    var creationDate: Date
    var isCompleted: Bool
    var content: String
    
    init(id: Int, content: String, creationDate: Date = Date()) {
        self.id = id
        self.content = content
        self.creationDate = creationDate
        self.isCompleted = false
    }
}

// MARK: CloudKit setup
extension Goal {
    var record: CKRecord {
        let record = CKRecord(recordType: "Goal")
        record["id"] = id as CKRecordValue
        record["creationDate"] = creationDate as CKRecordValue
        record["isCompleted"] = isCompleted as CKRecordValue
        record["content"] = content as CKRecordValue
        return record
    }
    
    convenience init?(record: CKRecord) {
        guard let id = record["id"] as? Int,
              let creationDate = record["creationDate"] as? Date,
              let isCompleted = record["isCompleted"] as? Bool,
              let content = record["content"] as? String
        else {
            return nil
        }
        
        self.init(id: id, content: content)
        self.creationDate = creationDate
        self.isCompleted = isCompleted
    }
}
