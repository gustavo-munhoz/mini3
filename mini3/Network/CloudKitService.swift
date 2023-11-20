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
    
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserPreferences", predicate: predicate)
        let dispatchGroup = DispatchGroup()

        var fetchedProjects = [Project]()
        var fetchedGoals = [Goal]()
        var fetchedPreferredColor = "AppPurple"
        var fetchedAvatar = "Avatar1"

        dispatchGroup.enter()
        privateDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
            switch result {
            case .failure(let error as NSError):
                if error.domain == CKErrorDomain, error.code == CKError.unknownItem.rawValue || error.code == CKError.limitExceeded.rawValue {
                    self.createUserPreferencesAndAssociatedData() { result in
                        switch result {
                        case .success(let newUser):
                            completion(.success(newUser))
                            print("- User record created.")
                        case .failure(let error):
                            completion(.failure(error))
                            print("<> Error creating user record: \(error.localizedDescription)")
                        }
                    }
                } else {
                    completion(.failure(error))
                    print("<!> Unknown error: \(error.localizedDescription)")
                }

            case .success((let matchResults, _)):
                if matchResults.isEmpty {
                    // Não encontrou nenhum registro, cria um novo usuário
                    self.createUserPreferencesAndAssociatedData() { result in
                        switch result {
                        case .success(let newUser):
                            completion(.success(newUser))
                            print("- User record created.")
                        case .failure(let error):
                            completion(.failure(error))
                            print("<> Error creating user record: \(error.localizedDescription)")
                        }
                    }
                } else if let record = try? matchResults.first?.1.get() {
                    // Processa o registro encontrado
                    fetchedPreferredColor = record["preferredColor"] as? String ?? "AppPurple"
                    fetchedAvatar = record["avatar"] as? String ?? "Avatar1"
                    let user = User(goals: fetchedGoals, projects: fetchedProjects, preferredColor: fetchedPreferredColor, avatar: fetchedAvatar)
                    user.userPreferencesRecord = record // Armazenando o CKRecord
                    completion(.success(user))
                    print("- Fetched color and avatar: \(fetchedPreferredColor), \(fetchedAvatar)")
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
            let user = User(goals: fetchedGoals, projects: fetchedProjects, preferredColor: fetchedPreferredColor, avatar: fetchedAvatar)
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
    
    func createUserPreferencesAndAssociatedData(completion: @escaping (Result<User, Error>) -> Void) {
        // Criar e configurar o registro 'UserPreferences'
        let newUserPreferencesRecord = CKRecord(recordType: "UserPreferences")
        newUserPreferencesRecord["preferredColor"] = "AppPurple"
        newUserPreferencesRecord["avatar"] = "Avatar1"


        // Salvar os registros no CloudKit
        let recordsToSave = [newUserPreferencesRecord]
        let saveOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)

        saveOperation.modifyRecordsResultBlock = { savedRecords in
            let user = User(goals: [], projects: [], preferredColor: "AppPurple", avatar: "Avatar1")
            user.userPreferencesRecord = newUserPreferencesRecord
            completion(.success(user))
        }

        privateDB.add(saveOperation)
    }
    
    func fetchUserPreferencesRecord(completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserPreferences", predicate: predicate)

        privateDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success((let matchResults, _)):
                if let record = try? matchResults.first?.1.get() {
                    completion(.success(record))
                } else {
                    completion(.failure(NSError(domain: "No UserPreferences record found", code: 0)))
                }
            }
        }
    }
    
    // MARK: Update data
    static func createProject(_ project: Project) -> AnyPublisher<Void, Error> {
        let record = project.record

        return Future<Void, Error> { promise in
            CKContainer.default().privateCloudDatabase.save(record) { _, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    static func createGoal(_ goal: Goal) -> AnyPublisher<Void, Error> {
        let record = goal.record

        return Future<Void, Error> { promise in
            CKContainer.default().privateCloudDatabase.save(record) { _, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUserPreferences(preferredColor: String, avatar: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchUserPreferencesRecord { result in
            switch result {
            case .success(let record):
                // Atualiza os valores
                record["preferredColor"] = preferredColor
                record["avatar"] = avatar
                
                // Reutiliza a função existente para salvar o registro
                CloudKitService.saveUpdatedRecord(record, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func saveUpdatedRecord(_ record: CKRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        CKContainer.default().privateCloudDatabase.add(modifyOperation)
    }
}
