//
//  HistoryStore.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import UIKit
import Combine

final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()
    @Published private(set) var items: [HistoryItem] = []

    struct HistoryItem: Identifiable {
        let id = UUID()
        let date: Date
        let prompt: String
        let usedAvatar: Bool
        let image: UIImage
    }

    func appendFinished(image: UIImage, prompt: String, usedAvatar: Bool) {
        items.insert(.init(date: Date(), prompt: prompt, usedAvatar: usedAvatar, image: image), at: 0)
    }
}
