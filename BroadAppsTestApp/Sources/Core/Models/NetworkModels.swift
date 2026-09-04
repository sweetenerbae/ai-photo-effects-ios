//
//  NetworkModels.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 18.10.25.
//

import Foundation

struct GenerationRequest: Codable {
    let type: String
    let prompt: String
    let templateId: Int?

    init(prompt: String, templateId: Int? = nil) {
        self.type = "fotobudka_txt2img"
        self.prompt = prompt
        self.templateId = templateId
    }

    enum CodingKeys: String, CodingKey {
        case type, prompt
        case templateId = "template_id"
    }
}

struct GenerationReadDTO: Codable {
    let id: String
    let type: String
    let status: String
    let result: String?
    let error: String?
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct UserCreateRequest: Codable {
    let apphudId: String

    enum CodingKeys: String, CodingKey {
        case apphudId = "apphud_id"
    }
}

struct UserCreateResponse: Codable {
    let id: String
    let apphudId: String
    let tokens: Int

    enum CodingKeys: String, CodingKey {
        case id, tokens
        case apphudId = "apphud_id"
    }
}

struct UserAuthorizeRequest: Codable {
    let userId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}
