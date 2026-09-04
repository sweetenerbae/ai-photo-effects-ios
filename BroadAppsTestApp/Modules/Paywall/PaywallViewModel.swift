//
//  PaywallViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 15.10.25.
//

import SwiftUI
import StoreKit
import Combine

@MainActor
final class PaywallViewModel: ObservableObject {
    enum Plan: String, CaseIterable, Identifiable {
        case weekly = "sub.weekly"
        case monthly = "sub.monthly"
        case monthlyDiscount = "sub.monthly.discount"

        var id: String { rawValue }

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
    @Published private(set) var isPurchasing = false
    @Published var errorMessage: String?

    private let subscriptions: SubscriptionManager

    init(subscriptions: SubscriptionManager) {
        self.subscriptions = subscriptions
    }

    convenience init() {
        self.init(subscriptions: .shared)
    }

    func onAppear() {
        Task {
            do {
                try await subscriptions.loadProducts()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func continueTapped() async -> Bool {
        guard !isPurchasing else { return false }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            return try await subscriptions.purchase(productID: selected.rawValue)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func restore() async {
        do {
            try await subscriptions.restore()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var isSubscribed: Bool { subscriptions.isSubscribed }
}
