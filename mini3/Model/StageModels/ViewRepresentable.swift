import Foundation
import SwiftUI
import Combine

// Protocolo para as views que representam modelos posicionáveis.
protocol ViewRepresentable {
//    associatedtype Model: Positionable
//    var model: Model { get set }
    var isSelected: Bool { get set }
    var onSelected: () -> Void { get set }
}
