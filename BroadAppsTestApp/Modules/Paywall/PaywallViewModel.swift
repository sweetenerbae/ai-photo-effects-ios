//
//  PaywallViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 15.10.25.
//

import SwiftUI
import StoreKit
import Combine

final class PaywallViewModel: ObservableObject {
    enum Plan: String, CaseIterable, Identifiable {
        case weekly = "sub.weekly"
        case monthly = "sub.monthly"
        case monthlyDiscount = "sub.monthly.discount"

        var id: String { rawValue }

        // Тексты как в макете
        var title: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .monthlyDiscount: return "Monthly"
            }
        }
        var subtitle: String {
            switch self {
            case .weekly: return ""
            case .monthly: return "$2 per month"
            case .monthlyDiscount: return "$1 per month"
            }
        }
        var badge: String? {
            switch self {
            case .weekly: return nil
            case .monthly: return "Save 40%"
            case .monthlyDiscount: return "Save 60%"
            }
        }
        var priceText: String {
            switch self {
            case .weekly: return "$5"
            case .monthly: return "$2"
            case .monthlyDiscount: return "$1"
            }
        }
    }

    @Published var selected: Plan = .monthlyDiscount
    @Published var isPurchasing = false

    private let subs = SubscriptionManager.shared

    func onAppear() {
        Task { await subs.loadProducts() }
    }

    @MainActor
    func continueTapped() async {
        guard !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        await subs.purchase(productID: selected.rawValue)
    }

    var isSubscribed: Bool { subs.isSubscribed }
}
