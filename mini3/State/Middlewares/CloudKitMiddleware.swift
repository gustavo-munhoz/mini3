//
//  CloudKitMiddleware.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 11/11/23.
//

import Combine


let cloudKitMiddleware: Middleware<AppState, AppAction> = { state, action in
    let cloudKitService = CloudKitService()
    
    switch action {
    case .createNewProject:
        let newProject = Project(id: (state.user?.projects.count ?? 1) + 1)
              
        return Just(AppAction.projectCreated(newProject))
                .setFailureType(to: Error.self)
                .catch { error in Just(AppAction.cloudKitError(error)) }
                .eraseToAnyPublisher()

        case .projectCreated(let project):
            return cloudKitService.saveProjectToCloudKit(project: project)
                    .map { _ in AppAction.projectSavedSuccessfully(project) }
                    .catch { Just(AppAction.cloudKitError($0)) }
                    .eraseToAnyPublisher()
        
    default:
        break
    }
    
    return Empty().eraseToAnyPublisher()
}
