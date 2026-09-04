//
//  AppEnvironment.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.
//

import Foundation

struct AppEnvironment {
    let effectsRepo: EffectsRepository
    let networkClient: NetworkClient
    let avatarService: AvatarServicing
    let imageGenService: ImageGenService

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        self.effectsRepo = AppConfig.isPortfolioMode
            ? MockEffectsRepository()
            : RemoteEffectsRepository(client: networkClient)
        self.avatarService = AvatarService(networkClient: networkClient)
        self.imageGenService = RealImageGenService(networkClient: networkClient)
    }
}

extension AppEnvironment {
    static let live = AppEnvironment(
        networkClient: NetworkClient(
            baseURL: AppConfig.baseURL,
            bearerToken: KeychainHelper.shared.getToken()
        )
    )
}
