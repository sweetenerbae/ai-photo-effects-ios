//
//  AuthViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 18.10.25.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    convenience init() {
        self.init(
            authService: AuthService(
                networkClient: AppEnvironment.live.networkClient
            )
        )
    }

    func autoLogin() async {
        if KeychainHelper.shared.getToken() != nil {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await authService.fullAuthProcess(userId: nil)
        } catch {
            self.error = "Auto-login failed: \(error.localizedDescription)"
        }
    }

    var isAuthenticated: Bool {
        KeychainHelper.shared.getToken() != nil
    }
}
