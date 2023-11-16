import Foundation
import SwiftUI
import Combine

// Protocolo para os modelos que podem ser posicionados.
protocol Positionable: Identifiable, ObservableObject, Identifiable, Codable {
    var id : UUID { get }
//    var content : String {get set}
    var relativeX: Double { get set }
    var relativeY: Double { get set }
    var isVisible: Bool { get set }
    var cancellable: AnyCancellable? { get set }
}
