import UIKit

struct PortfolioDemoData {
    nonisolated static let assetScheme = "asset://"

    static let demoAvatars: [FotobudkaAvatar] = [
        FotobudkaAvatar(id: 9001, title: "Editorial Muse", preview: assetURL("ob_face_up"), gender: "f", is_active: true),
        FotobudkaAvatar(id: 9002, title: "Street Portrait", preview: assetURL("ob_face_center"), gender: "f", is_active: false),
        FotobudkaAvatar(id: 9003, title: "Studio Look", preview: assetURL("ob_face_down"), gender: "m", is_active: false),
    ]

    static func demoCategories() -> [PhotoStyleCategory] {
        [
            PhotoStyleCategory(
                id: 1,
                title: "Portrait Concepts",
                description: "Sample portfolio templates backed by local assets.",
                preview: assetURL("effects1"),
                previewWoman: assetURL("effects1"),
                previewMan: assetURL("effects2"),
                code: "portrait_concepts",
                templates: [
                    PhotoStyle(id: 101, title: "Studio Glow", preview: assetURL("effects1"), previewProduction: assetURL("effects1"), prompt: "Soft studio portrait lighting", isEnabled: true),
                    PhotoStyle(id: 102, title: "Doll Editorial", preview: assetURL("doll_1"), previewProduction: assetURL("doll_1"), prompt: "Fashion editorial portrait", isEnabled: true),
                    PhotoStyle(id: 103, title: "Trend Cover", preview: assetURL("effects3"), previewProduction: assetURL("effects3"), prompt: "Magazine cover photo", isEnabled: true),
                ]
            ),
            PhotoStyleCategory(
                id: 2,
                title: "Social Content",
                description: "Demo templates for the portfolio build.",
                preview: assetURL("effects4"),
                previewWoman: assetURL("effects5"),
                previewMan: assetURL("effects6"),
                code: "social_content",
                templates: [
                    PhotoStyle(id: 201, title: "Bold Poster", preview: assetURL("effects4"), previewProduction: assetURL("effects4"), prompt: "Bold poster style portrait", isEnabled: true),
                    PhotoStyle(id: 202, title: "Playful Pop", preview: assetURL("doll_2"), previewProduction: assetURL("doll_2"), prompt: "Playful pop-art portrait", isEnabled: true),
                    PhotoStyle(id: 203, title: "Night Editorial", preview: assetURL("doll_3"), previewProduction: assetURL("doll_3"), prompt: "Night city fashion portrait", isEnabled: true),
                ]
            ),
        ]
    }

    nonisolated static func assetURL(_ assetName: String) -> String {
        "\(assetScheme)\(assetName)"
    }

    nonisolated static func assetName(from value: String) -> String? {
        guard value.hasPrefix(assetScheme) else {
            return nil
        }

        return String(value.dropFirst(assetScheme.count))
    }

    static func makePreviewImage(named assetName: String) -> UIImage {
        UIImage(named: assetName) ?? UIImage(systemName: "photo") ?? UIImage()
    }
}

struct MockEffectsRepository: EffectsRepository {
    func fetchCategories(lang: String,
                         gender: String,
                         tag: String?,
                         showAll: Bool) async throws -> [PhotoStyleCategory] {
        PortfolioDemoData.demoCategories()
    }
}

extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        guard !queryItems.isEmpty else {
            return self
        }

        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        return components?.url ?? self
    }
}
