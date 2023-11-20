//
//  CloudKitMiddleware.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 11/11/23.
//

import Combine
import CloudKit

let cloudKitMiddleware: Middleware<AppState, AppAction> = { state, action in
    let cloudKitService = CloudKitService()
    
    switch action {
    // MARK: - User
    case .updateUserPreferences(let preferredColor, let avatar):
        guard let userPreferencesRecord = state.user?.userPreferencesRecord else {
            print("Erro: Registro de preferências do usuário não encontrado.")
            return Empty().eraseToAnyPublisher()
        }

        return Future<Void, Error> { promise in
            userPreferencesRecord["preferredColor"] = preferredColor
            userPreferencesRecord["avatar"] = avatar

            CloudKitService.saveUpdatedRecord(userPreferencesRecord) { result in
                switch result {
                case .success():
                    promise(.success(()))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .map { _ in AppAction.userPreferencesUpdatedSuccessfully }
        .catch { Just(AppAction.cloudKitError($0)) }
        .eraseToAnyPublisher()
        
    // MARK: - Project
    case .createNewProject:
        let newProjectID = state.user?.projects.count ?? 1
        let newProject = Project(id: newProjectID)
        newProject.cloudKitRecord = CKRecord(recordType: "Project")
        
        return Just(AppAction.projectCreated(newProject))
            .eraseToAnyPublisher()


    case .projectCreated(let project):
        state.user?.projects.append(project)
        
        return CloudKitService.createProject(project)
            .map { _ in AppAction.projectSavedSuccessfully(project) }
            .catch { Just(AppAction.cloudKitError($0)) }
            .eraseToAnyPublisher()

        
    case .updateProject(let project):
        guard let cloudKitRecord = project.cloudKitRecord else {
            print("Erro: CKRecord não encontrado para atualização.")
            return Empty().eraseToAnyPublisher()
        }

        project.updateRecord(cloudKitRecord)
        return Just(AppAction.projectUpdatedSuccessfully(project))
            .eraseToAnyPublisher()

        
    // MARK: - Goal
    case .createNewGoal(let content):
        let newGoalID = state.user?.goals.count ?? 1
        let newGoal = Goal(id: newGoalID, content: content, date: state.currentDate)
        newGoal.cloudKitRecord = CKRecord(recordType: "Goal")

        return Just(AppAction.goalCreated(newGoal))
            .eraseToAnyPublisher()

    case .goalCreated(let goal):
        state.user?.goals.append(goal)
        
        return CloudKitService.createGoal(goal)
            .map { _ in AppAction.goalCreatedSuccessfully(goal) }
            .catch { Just(AppAction.cloudKitError($0)) }
            .eraseToAnyPublisher()

    case .updateGoal(let goal):
        guard let cloudKitRecord = goal.cloudKitRecord else {
            print("Erro: CKRecord não encontrado para atualização.")
            return Empty().eraseToAnyPublisher()
        }

        goal.updateRecord(cloudKitRecord)
        return Just(AppAction.goalUpdatedSuccessfully(goal))
            .eraseToAnyPublisher()

         
    default:
        break
    }
    
    return Empty().eraseToAnyPublisher()
}
