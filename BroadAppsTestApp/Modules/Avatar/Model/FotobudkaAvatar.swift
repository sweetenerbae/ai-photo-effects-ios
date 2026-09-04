//
//  FotobudkaAvatar.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 18.10.25.
//
import UIKit

// Модель для API аватаров
struct FotobudkaAvatar: Codable, Identifiable {
    let id: Int
    let title: String?
    let preview: String?
    let gender: String
    let is_active: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, preview, gender
        case is_active = "is_active"
    }
}

struct FotobudkaAvatarUpdateDTO: Codable {
    let gender: String
    let title: String
    let avatarId: String?
    let isActive: Bool?
}

struct BodyRunFotobudkaAvatar: Codable {
    let photos: [Data]
    let preview: Data?
}
