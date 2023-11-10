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
    let publicDB: CKDatabase
    
    init(container: CKContainer = .default()) {
        self.container = container
        self.publicDB = container.publicCloudDatabase
    }

    // MARK: Account status
    
    func fetchAccountStatus(completion: @escaping (CKAccountStatus) -> Void) {
        CKContainer.default().accountStatus { (accountStatus, error) in
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
    
    func fetchOrCreateUser(withRecordName recordName: String, completion: @escaping (Result<User, Error>) -> Void) {
        let recordID = CKRecord.ID(recordName: recordName)
        publicDB.fetch(withRecordID: recordID) { fetchedRecord, error in
            if let fetchedRecord = fetchedRecord {
                if let user = User(record: fetchedRecord) {
                    completion(.success(user))
                } else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Record schema mismatch"])
                    completion(.failure(error))
                }
            } else {
                let newRecord = CKRecord(recordType: "User")
                self.publicDB.save(newRecord) { savedRecord, error in
                    if let savedRecord = savedRecord {
                        if let user = User(record: savedRecord) {
                            completion(.success(user))
                        } else {
                            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Record schema mismatch"])
                            completion(.failure(error))
                        }
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    }
                }
            }
        }
    }
    
    func updateUser(_ user: User, completion: @escaping (Result<User, Error>) -> Void) {
        publicDB.save(user.record) { savedRecord, error in
            if let error = error {
                completion(.failure(error))
            } else if let savedRecord = savedRecord {
                if let updatedUser = User(record: savedRecord) {
                    completion(.success(updatedUser))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
            }
        }
    }

    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        container.fetchUserRecordID { userRecordID, error in
            if let error = error {
                completion(.failure(error))
            } else if let userRecordID = userRecordID {
                self.fetchOrCreateUser(withRecordName: userRecordID.recordName) { result in
                    switch result {
                    case .success(let user):
                        completion(.success(user))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
            }
        }
    }
    
    // TODO: Cache
    
    private func cacheUser(_ user: User) {
        do {
            let userData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userData, forKey: "cachedUser")
        } catch {
            print("Failed to encode user: \(error)")
        }
    }

    private func getCachedUser() -> User? {
        if let userData = UserDefaults.standard.data(forKey: "cachedUser") {
            do {
                let user = try JSONDecoder().decode(User.self, from: userData)
                return user
            } catch {
                print("Failed to decode user: \(error)")
                return nil
            }
        }
        return nil
    }
}
