//
//  URLResolver.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 18.10.25.
//

import Foundation

struct URLResolver {
    static func absolute(_ path: String?) -> URL? {
        guard let path = path?.trimmingCharacters(in: .whitespacesAndNewlines),
              !path.isEmpty else {
            return nil
        }

        if let url = URL(string: path), let scheme = url.scheme?.lowercased() {
            guard ["http", "https"].contains(scheme), url.host != nil else {
                return nil
            }
            return url
        }

        let normalizedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return AppConfig.baseURL.appendingPathComponent(normalizedPath)
    }
}
