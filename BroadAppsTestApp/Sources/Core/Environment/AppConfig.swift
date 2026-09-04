//
//  AppConfig.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.

import Foundation

enum AppConfig {
    private static let info = Bundle.main.infoDictionary ?? [:]

    static let baseURL: URL = {
        let rawValue = (info["BASE_URL"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let rawValue,
           let url = URL(string: rawValue),
           let scheme = url.scheme?.lowercased(),
           ["http", "https"].contains(scheme),
           url.host != nil {
            return url
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "portfolio-demo.invalid"
        return components.url ?? URL(fileURLWithPath: "/")
    }()

    static let apphudApiKey = (info["APPHUD_API_KEY"] as? String) ?? "portfolio-demo-key"
    static let apphudIdSeed = (info["APPHUD_ID_SEED"] as? String) ?? "portfolio-demo-seed"
    static let appDisplayName = (info["APP_DISPLAY_NAME"] as? String) ?? "Portfolio Demo"
    static let isPortfolioMode: Bool = {
        let rawValue = (info["PORTFOLIO_MODE"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return ["1", "true", "yes"].contains(rawValue)
    }()
}
