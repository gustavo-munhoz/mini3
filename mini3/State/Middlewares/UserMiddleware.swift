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
                        cloudKitService.fetchUser() { result in
                            switch result {
                            case .success(let user):
                                promise(.success(.userRecordFetchedOrCreated(user)))
                            case .failure(let error):
                                promise(.success(.cloudKitError(error)))
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
