//
//  AvatarLibrary.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 13.10.25.
//

import SwiftUI
import Combine

final class AvatarLibrary: ObservableObject {
    static let shared = AvatarLibrary()
    @Published private(set) var avatars: [AiPhotoViewModel.Avatar] = []

    func add(name: String, image: UIImage) {
        avatars.append(.init(name: name, image: image))
    }
}
