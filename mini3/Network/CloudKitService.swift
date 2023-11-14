//
//  CloudKitService.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import CloudKit
import Combine
import AppKit

class CloudKitService {
    let container: CKContainer
    let privateDB: CKDatabase
    
    init() {
        self.container = CKContainer.default()
        self.privateDB = container.privateCloudDatabase
    }

    // MARK: Account status
    
    func fetchAccountStatus(completion: @escaping (CKAccountStatus) -> Void) {
        self.container.accountStatus { (accountStatus, error) in
            switch accountStatus {
            case .available:
                print("icloud connected")
                break
                
            case .noAccount:
                let alert = NSAlert()
                alert.messageText = "iCloud Account Required"
                alert.informativeText = "Please sign in to your iCloud account to use this feature."
                alert.addButton(withTitle: "OK")
                alert.runModal()

            case .restricted:
                let alert = NSAlert()
                alert.messageText = "iCloud Access Restricted"
                alert.informativeText = "iCloud access is restricted on this device."
                alert.addButton(withTitle: "OK")
                alert.runModal()

            case .couldNotDetermine:
                let alert = NSAlert()
                alert.messageText = "iCloud Status Error"
                alert.informativeText = "Could not determine iCloud account status."
                alert.addButton(withTitle: "OK")
                alert.runModal()
                
            default:
                let alert = NSAlert()
                alert.messageText = "iCloud Status Error"
                alert.informativeText = "iCloud access may be temporarily unavailable."
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            completion(accountStatus)
        }
    }
    
    // MARK: User-related methods
    
    func fetchUser(fullName: String, completion: @escaping (Result<User, Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserPreferences", predicate: predicate)
        let dispatchGroup = DispatchGroup()

        var fetchedProjects = [Project]()
        var fetchedGoals = [Goal]()
        var fetchedFullName = fullName
        var fetchedPreferredColor = "AppPurple"

        dispatchGroup.enter()
        privateDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
            switch result {
            case .failure(let error as NSError):
                if error.domain == CKErrorDomain, error.code == CKError.unknownItem.rawValue {
                    self.createUserPreferencesAndAssociatedData(fullName: fullName) { result in
                        switch result {
                        case .success(let newUser):
                            completion(.success(newUser))
                            print("- User record created: \(newUser.fullName)")
                            
                        case .failure(let error):
                            completion(.failure(error))
                            print("<> Error creating user record: \(error.localizedDescription)")
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    completion(.failure(error))
                    print("<!> Unknown error: \(error.localizedDescription)")
                    dispatchGroup.leave()
                }

            case .success((let matchResults, _)):
                if let record = try? matchResults.first?.1.get() {
                    fetchedFullName = record["fullName"] as? String ?? fullName
                    fetchedPreferredColor = record["preferredColor"] as? String ?? "AppPurple"
                    print("- Fetched name and color: \(fetchedFullName), \(fetchedPreferredColor)")
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.enter()
        fetchProjects { result in
            switch result {
            case .success(let projects):
                fetchedProjects = projects
                
            case .failure(let error):
                print("<!> Error fetching projects: \(error)")
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        fetchGoals { result in
            switch result {
            case .success(let goals):
                fetchedGoals = goals
                
            case .failure(let error):
                print("<!> Error fetching goals: \(error)")
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            let user = User(fullName: fetchedFullName, goals: fetchedGoals, projects: fetchedProjects, preferredColor: fetchedPreferredColor)
            print("- User created: \(fetchedFullName)")
            completion(.success(user))
        }
    }
    
    func fetchProjects(completion: @escaping (Result<[Project], Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Project", predicate: predicate)

        privateDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success((let matchResults, _)):
                let records = matchResults.compactMap { try? $0.1.get() }
                let projects = records.compactMap { Project(record: $0) }
                completion(.success(projects))
                print("- Fetched projects: \(projects)")
            }
        }
    }

    func fetchGoals(completion: @escaping (Result<[Goal], Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Goal", predicate: predicate)

        privateDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success((let matchResults, _)):
                let records = matchResults.compactMap { try? $0.1.get() }
                let goals = records.compactMap { Goal(record: $0) }
                completion(.success(goals))
                print("- Fetched goals: \(goals)")
            }
        }
    }
    
    func createUserPreferencesAndAssociatedData(fullName: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Criar e configurar o registro 'UserPreferences'
        let newUserPreferencesRecord = CKRecord(recordType: "UserPreferences")
        newUserPreferencesRecord["fullName"] = fullName
        newUserPreferencesRecord["preferredColor"] = "AppPurple"

        // Criar e configurar o registro 'Project'
        let newProjectRecord = CKRecord(recordType: "Project")
        // Configure os campos do projeto conforme necessário

        // Criar e configurar o registro 'Goal'
        let newGoalRecord = CKRecord(recordType: "Goal")
        // Configure os campos da meta conforme necessário

        // Salvar os registros no CloudKit
        let recordsToSave = [newUserPreferencesRecord, newProjectRecord, newGoalRecord]
        let saveOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)

        saveOperation.modifyRecordsResultBlock = { savedRecords in
            let user = User(fullName: fullName, goals: [], projects: [], preferredColor: "AppPurple")
            completion(.success(user))
        }

        privateDB.add(saveOperation)
    }
    
    // MARK: Update data
    
    func saveProjectToCloudKit(project: Project) -> AnyPublisher<Void, Error> {
        let record = project.record // Converter Project para CKRecord
        
        return Future<Void, Error> { promise in
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            modifyOperation.savePolicy = .changedKeys
            modifyOperation.modifyRecordsResultBlock = {_ in
                promise(.success(()))
            }
            self.privateDB.add(modifyOperation)
        }
        .eraseToAnyPublisher()
    }
}
