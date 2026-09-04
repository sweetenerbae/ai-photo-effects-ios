//
//  EffectsEntities.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.
//

import Foundation

struct PhotoStyleCategory: Identifiable, Equatable, Decodable {
    let id: Int
    let title: String?
    let description: String?
    let preview: String?
    let previewWoman: String?
    let previewMan: String?
    let code: String?
    let templates: [PhotoStyle]

    enum CodingKeys: String, CodingKey {
        case id, title, description, preview, templates, code
        case previewWoman = "preview_woman"
        case previewMan   = "preview_man"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        preview = try container.decodeIfPresent(String.self, forKey: .preview)
        previewWoman = try container.decodeIfPresent(String.self, forKey: .previewWoman)
        previewMan = try container.decodeIfPresent(String.self, forKey: .previewMan)
        code = try container.decodeIfPresent(String.self, forKey: .code)

        templates = try container.decodeIfPresent([PhotoStyle].self, forKey: .templates) ?? []
    }

    var displayTitle: String {
        title ?? code ?? "Category \(id)"
    }

    func displayPreview(for gender: String) -> String? {
        switch gender.lowercased() {
        case "f": return previewWoman ?? preview
        case "m": return previewMan   ?? preview
        default:  return preview
        }
    }

    init(id: Int,
         title: String?,
         description: String?,
         preview: String?,
         previewWoman: String?,
         previewMan: String?,
         code: String?,
         templates: [PhotoStyle]) {
        self.id = id
        self.title = title
        self.description = description
        self.preview = preview
        self.previewWoman = previewWoman
        self.previewMan = previewMan
        self.code = code
        self.templates = templates
    }
}

struct PhotoStyle: Identifiable, Equatable, Decodable {
    let id: Int
    let title: String?
    let preview: String?
    let previewProduction: String?
    let prompt: String?
    let isEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, preview, prompt
        case previewProduction = "preview_production"
        case isEnabled = "is_enabled"
    }

    var displayTitle: String { title ?? "Style \(id)" }
    var displayPreview: String? { previewProduction ?? preview }

    init(id: Int,
         title: String?,
         preview: String?,
         previewProduction: String?,
         prompt: String?,
         isEnabled: Bool?) {
        self.id = id
        self.title = title
        self.preview = preview
        self.previewProduction = previewProduction
        self.prompt = prompt
        self.isEnabled = isEnabled
    }
}
