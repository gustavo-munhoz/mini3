//
//  FetchWordsMiddleware.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 13/11/23.
//

import Foundation
import Combine

//let wordsMiddleware: Middleware<AppState, AppAction> = { state, action in
//    switch action {
//    case .fetchRelatedWords(let word):
//        return Deferred {
//            Future<AppAction, Never> { promise in
//                WordsService.shared.fetchRelatedWords(word: word) { result in
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(let words):
//                            // Transforma as palavras em WordPositions
//                            let wordPositions = words.map { word in
//                                // As funções calculateFontSize e generateNonOverlappingPosition precisam estar acessíveis aqui
//                                GeometryUtils.generateNonOverlappingPosition(
//                                    screenSize: state.screenSize,
//                                    word: word,
//                                    fontSize: GeometryUtils.calculateFontSize(screenSize: state.screenSize),
//                                    existingWordPositions: (state.currentProject?.appearingWords ?? []) + (state.currentProject?.selectedWords ?? []),
//                                    circleSize: state.screenSize.width * 0.9)
//                            }
//                            promise(.success(.fetchWordsSuccess(wordPositions)))
//                        case .failure(let error):
//                            promise(.success(.fetchWordsFailure(error)))
//                        }
//                    }
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    
//    case .hideWord(let wordPosition):
//        return Empty().eraseToAnyPublisher()
//        
//    default:
//        return Empty().eraseToAnyPublisher()
//    }
//}

