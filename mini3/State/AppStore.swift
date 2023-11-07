//
//  Store.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 31/10/23.
//

import SwiftUI
import Combine

typealias AppStore = Store<AppState, AppAction>

class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State
    
    private let reducer: Reducer<State, Action>
    private let queue = DispatchQueue(
        label: "munhoz.dev.mini3",
        qos: .userInitiated)
    
    private let middlewares: [Middleware<State, Action>]
    private var cancellables = Set<AnyCancellable>()

    init(initial: State,
         reducer: @escaping Reducer<State, Action>,
         middlewares: [Middleware<State, Action>] = []
    ) {
        self.state = initial
        self.reducer = reducer
        self.middlewares = middlewares
    }

    func dispatch(_ action: Action) {
        queue.sync {
            self.dispatch(self.state, action)
        }
    }

    private func dispatch(_ currentState: State, _ action: Action) {
        let newState = reducer(currentState, action)
        
        middlewares.forEach { middleware in
            let publisher = middleware(newState, action)
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: dispatch)
                .store(in: &cancellables)
        }
        
        state = newState
    }
}
