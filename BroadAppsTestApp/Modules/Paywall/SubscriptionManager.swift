import Combine
import StoreKit

enum SubscriptionError: LocalizedError {
    case productUnavailable
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return "The selected subscription is currently unavailable."
        case .failedVerification:
            return "The App Store transaction could not be verified."
        }
    }
}

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var isSubscribed = false

    let productIDs = ["sub.weekly", "sub.monthly", "sub.monthly.discount"]

    private let isDemoMode: Bool
    private var products: [Product] = []

    init(isDemoMode: Bool) {
        self.isDemoMode = isDemoMode
    }

    convenience init() {
        self.init(isDemoMode: AppConfig.isPortfolioMode)
    }

    func loadProducts() async throws {
        guard !isDemoMode else { return }
        products = try await Product.products(for: productIDs)
        try await refreshEntitlements()
    }

    func product(for id: String) -> Product? {
        products.first(where: { $0.id == id })
    }

    @discardableResult
    func purchase(productID: String) async throws -> Bool {
        if isDemoMode {
            isSubscribed = true
            return true
        }
        guard let product = product(for: productID) else {
            throw SubscriptionError.productUnavailable
        }

        switch try await product.purchase() {
        case .success(let result):
            let transaction = try verified(result)
            await transaction.finish()
            isSubscribed = true
            return true
        case .pending, .userCancelled:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async throws {
        if isDemoMode {
            isSubscribed = true
            return
        }
        try await AppStore.sync()
        try await refreshEntitlements()
    }

    private func refreshEntitlements() async throws {
        var hasActiveSubscription = false
        for await result in Transaction.currentEntitlements {
            let transaction = try verified(result)
            if productIDs.contains(transaction.productID), transaction.revocationDate == nil {
                hasActiveSubscription = true
            }
        }
        isSubscribed = hasActiveSubscription
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw SubscriptionError.failedVerification
        }
    }
}
