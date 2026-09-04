//
//  EffectsRepository.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.
//

import Foundation

protocol EffectsRepository {
    func fetchCategories(lang: String,
                         gender: String,
                         tag: String?,
                         showAll: Bool) async throws -> [PhotoStyleCategory]
}
