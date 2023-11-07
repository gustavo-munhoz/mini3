//
//  Middleware.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 01/11/23.
//

import Combine

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>
