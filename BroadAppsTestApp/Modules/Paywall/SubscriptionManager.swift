//
//  SubscriptionManager.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 15.10.25.
//

import StoreKit
import Combine

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // кнопка "Continue" просто включает подписку локально.
    var mockMode = true

    @Published private(set) var isSubscribed: Bool = false

    //  идентификаторы продуктов  (позже в App Store Connect)
    let productIDs = ["sub.weekly", "sub.monthly", "sub.monthly.discount"]

    private var products: [Product] = []

    func loadProducts() async {
        guard !mockMode else { return }
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            // todo
        }
    }

    func product(for id: String) -> Product? {
        products.first(where: { $0.id == id })
    }

    func purchase(productID: String) async {
        if mockMode {
            // имитация успешной покупки
            isSubscribed = true
            return
        }
        guard let product = product(for: productID) else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(_):
                isSubscribed = true
            default:
                break
            }
        } catch { }
    }

    func restore() async {
        if mockMode {
            isSubscribed = true
            return
        }
        do {
            try await AppStore.sync()
        } catch { }
    }
}
