//
//  RateUsManager.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import StoreKit
import UIKit

enum RateUsManager {
    static func requestReviewOrRedirect(appID: String) {
        // 1) Пытаемся показать системный prompt (показывается не всегда)
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
        }

        // 2) На всякий случай через 0.7с откроем страницу “Write a Review”
        //    (если промпт показался — пользователь просто увидит системное окно)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            let urlString = "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
