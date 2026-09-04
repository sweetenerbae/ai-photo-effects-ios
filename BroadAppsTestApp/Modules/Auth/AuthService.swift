import Foundation

protocol AuthServiceProtocol {
    func createUser(apphudId: String) async throws -> String
    func authorizeUser(backendUserId: String) async throws -> String
    func fullAuthProcess(userId: String?) async throws -> String
}

enum AuthServiceError: LocalizedError {
    case secureStorageFailed

    var errorDescription: String? {
        "The session could not be stored securely on this device."
    }
}

final class AuthService: AuthServiceProtocol {
    private enum Keys {
        static let deviceId = "device_id"
        static let backendUserId = "backend_user_id"
    }

    private let networkClient: NetworkClient
    private let userDefaults: UserDefaults
    private let tokenStore: TokenStoring

    init(
        networkClient: NetworkClient,
        userDefaults: UserDefaults = .standard,
        tokenStore: TokenStoring = KeychainHelper.shared
    ) {
        self.networkClient = networkClient
        self.userDefaults = userDefaults
        self.tokenStore = tokenStore
    }

    func createUser(apphudId: String) async throws -> String {
        if AppConfig.isPortfolioMode {
            return "portfolio-user-\(apphudId.prefix(8))"
        }

        let response: UserCreateResponse = try await networkClient.post(
            "/api/users",
            body: UserCreateRequest(apphudId: apphudId)
        )
        return response.id
    }

    func authorizeUser(backendUserId: String) async throws -> String {
        if AppConfig.isPortfolioMode {
            return "portfolio-demo-token"
        }

        let response: TokenResponse = try await networkClient.post(
            "/api/users/authorize",
            body: UserAuthorizeRequest(userId: backendUserId)
        )
        return response.accessToken
    }

    func fullAuthProcess(userId: String? = nil) async throws -> String {
        let backendUserId: String
        if AppConfig.isPortfolioMode {
            backendUserId = "portfolio-user"
        } else if let storedId = userDefaults.string(forKey: Keys.backendUserId) {
            backendUserId = storedId
        } else {
            let deviceId = userId ?? getOrCreateDeviceId()
            backendUserId = try await createUser(apphudId: deviceId)
            userDefaults.set(backendUserId, forKey: Keys.backendUserId)
        }

        let token = try await authorizeUser(backendUserId: backendUserId)
        if AppConfig.isPortfolioMode {
            await networkClient.setToken(token)
            return token
        }
        guard tokenStore.saveToken(token) else {
            throw AuthServiceError.secureStorageFailed
        }
        await networkClient.setToken(token)
        return token
    }

    private func getOrCreateDeviceId() -> String {
        if let savedId = userDefaults.string(forKey: Keys.deviceId) {
            return savedId
        }
        let newId = UUID().uuidString
        userDefaults.set(newId, forKey: Keys.deviceId)
        return newId
    }
}
