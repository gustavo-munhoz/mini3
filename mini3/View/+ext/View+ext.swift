//
//  View+ex.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 13/11/23.
//

import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

//extension View {
//    func onForceClick(minimumPressure: CGFloat, perform action: @escaping () -> Void) -> some View {
//        self.background(ForceClickGestureView(minimumPressure: minimumPressure, action: action))
//    }
//}
//
//struct ForceClickGestureView: NSViewRepresentable {
//    var minimumPressure: CGFloat
//    var action: () -> Void
//
//    func makeNSView(context: Context) -> NSView {
//        let view = NSView()
//        let recognizer = NSPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.forceClickRecognized))
//        recognizer.minimumPressDuration = 0
//        recognizer.allowableMovement = 10
//        recognizer.pressure = minimumPressure
//        view.addGestureRecognizer(recognizer)
//        return view
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(action: action)
//    }
//
//    class Coordinator: NSObject {
//        var action: () -> Void
//
//        init(action: @escaping () -> Void) {
//            self.action = action
//        }
//
//        @objc func forceClickRecognized(recognizer: NSPressGestureRecognizer) {
//            if recognizer.state == .recognized {
//                action()
//            }
//        }
//    }
//}
