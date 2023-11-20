//
//  Goal.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import CloudKit

class Goal: Codable {
    var id: Int
    var date: Date
    var isCompleted: Bool
    var content: String
    var cloudKitRecord: CKRecord?

    init(id: Int, content: String, date: Date = Date(), isCompleted: Bool = false) {
        self.id = id
        self.content = content
        self.date = date
        self.isCompleted = isCompleted
    }
    
    enum CodingKeys: String, CodingKey {
       case id
       case date
       case isCompleted
       case content
   }
}

// MARK: CloudKit setup
extension Goal {
    var record: CKRecord {
        if let existingRecord = cloudKitRecord {
            updateRecord(existingRecord)
            return existingRecord
            
        } else {
            let newRecord = CKRecord(recordType: "Goal")
            updateRecord(newRecord)
            cloudKitRecord = newRecord
            return newRecord
        }
    }
    
    func updateRecord(_ record: CKRecord) {
        record["id"] = id as CKRecordValue
        record["date"] = date as CKRecordValue
        record["isCompleted"] = isCompleted as CKRecordValue
        record["content"] = content as CKRecordValue
        
        CloudKitService.saveUpdatedRecord(record) { result in
            switch result {
            case .success():
                print("Goal atualizado com sucesso no CloudKit")
            case .failure(let error):
                print("Erro ao atualizar o goal: \(error)")
            }
        }
    }
    
    convenience init?(record: CKRecord) {
        guard let id = record["id"] as? Int,
              let date = record["date"] as? Date,
              let isCompleted = record["isCompleted"] as? Bool,
              let content = record["content"] as? String
        else {
            return nil
        }
        
        self.init(id: id, content: content, date: date, isCompleted: isCompleted)
        self.cloudKitRecord = record
    }
}
