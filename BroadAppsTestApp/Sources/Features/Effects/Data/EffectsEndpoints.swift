//
//  EffectsEndpoints.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.
//

import Foundation

enum EffectsEndpoints {
    static func imageTemplates(lang: String,
                               gender: String,
                               tag: String?,
                               showAll: Bool) -> (path: String, query: [URLQueryItem]) {
        var q: [URLQueryItem] = [
            .init(name: "lang", value: lang),
            .init(name: "gender", value: gender),
            .init(name: "showAll", value: showAll ? "true" : "false"),
        ]
        if let tag { q.append(.init(name: "tag", value: tag)) }
        return ("/api/generations/fotobudka/image-templates", q)
    }
}
