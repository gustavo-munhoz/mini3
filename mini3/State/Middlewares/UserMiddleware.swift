//
//  UserMiddleware.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 02/11/23.
//

import Combine
import CloudKit

let userMiddleware: Middleware<AppState, AppAction> = { state, action in
    let cloudKitService = CloudKitService()
    
    switch action {
    case .checkiCloudAccountStatus:
        return Deferred {
            Future<AppAction, Never> { promise in
                cloudKitService.fetchAccountStatus { accountStatus in
                    switch accountStatus {
                    case .available:
                        CKContainer.default().fetchUserRecordID { recordID, error in
                            if let recordID = recordID, error == nil {
                                CKContainer.default().fetchShareParticipant(withUserRecordID: recordID) { shareParticipant, error in
                                    if let error = error {
                                        // Tratar o erro
                                        promise(.success(.cloudKitError(error)))
                                    } else if let components = shareParticipant?.userIdentity.nameComponents {
                                        let fullName = [components.givenName, components.familyName].compactMap { $0 }.joined(separator: " ")
                                        cloudKitService.fetchUser(fullName: fullName) { result in
                                            switch result {
                                            case .success(let user):
                                                promise(.success(.userRecordFetchedOrCreated(user)))
                                            case .failure(let error):
                                                promise(.success(.cloudKitError(error)))
                                            }
                                        }
                                    } else {
                                        // Proceder sem o nome do usuário
                                        cloudKitService.fetchUser(fullName: "Your name!") { result in
                                            switch result {
                                            case .success(let user):
                                                promise(.success(.userRecordFetchedOrCreated(user)))
                                            case .failure(let error):
                                                promise(.success(.cloudKitError(error)))
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Erro ao buscar recordID
                                promise(.success(.iCloudStatusError))
                            }
                        }
                    default:
                        promise(.success(.iCloudStatusError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()

        
    default:
        return Empty().eraseToAnyPublisher()
    }
}
