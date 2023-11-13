//
//  MediaItem.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 13/11/23.
//

import Foundation

struct MediaItem: Identifiable {
    let id: UUID = UUID()
    let title: String
    let thumbnailURL: URL
    var relativeX: CGFloat
    var relativeY: CGFloat
}
