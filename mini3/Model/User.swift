//
//  User.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import CloudKit

class User: Codable {
    var id: String
    var fullName: String
    var email: String
    var goals: [Goal]
    var projects: [Project]
    
    init(id: String, fullName: String, email: String, goals: [Goal] = [], projects: [Project] = []) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.goals = goals
        self.projects = projects
    }
}


// MARK: CloudKit setup
extension User {
    var record: CKRecord {
        let record = CKRecord(recordType: "User")
        record["id"] = id as CKRecordValue
        record["fullName"] = fullName as CKRecordValue
        record["email"] = email as CKRecordValue
        
        let goalRecords = goals.map { $0.record }
        let projectRecords = projects.map { $0.record }
        record["goals"] = goalRecords as CKRecordValue
        record["projects"] = projectRecords as CKRecordValue
        
        return record
    }
    
    convenience init?(record: CKRecord) {
        guard let id = record["id"] as? String,
              let fullName = record["fullName"] as? String,
              let email = record["email"] as? String,
              let goalRecords = record["goals"] as? [CKRecord],
              let projectRecords = record["projects"] as? [CKRecord]
        else {
            return nil
        }
        
        let goals = goalRecords.compactMap { Goal(record: $0) }
        let projects = projectRecords.compactMap { Project(record: $0) }
        
        self.init(id: id, fullName: fullName, email: email, goals: goals, projects: projects)
    }
}
