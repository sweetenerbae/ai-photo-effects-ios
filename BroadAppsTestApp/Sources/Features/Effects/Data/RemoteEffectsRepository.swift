//
//  RemoteEffectsRepository.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.
//

import Foundation

struct RemoteEffectsRepository: EffectsRepository {
    let client: NetworkClient

    func fetchCategories(lang: String,
                         gender: String,
                         tag: String?,
                         showAll: Bool) async throws -> [PhotoStyleCategory] {
        let ep = EffectsEndpoints.imageTemplates(lang: lang, gender: gender, tag: tag, showAll: showAll)
        return try await client.get(ep.path, query: ep.query)
    }
}
