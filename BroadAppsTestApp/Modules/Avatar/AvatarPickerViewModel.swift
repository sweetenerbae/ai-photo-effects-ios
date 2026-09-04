//
//  vaatarPickerViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 20.10.25.
//
import SwiftUI
import Combine

@MainActor
final class AvatarPickerViewModel: ObservableObject {
    @Published private(set) var avatars: [FotobudkaAvatar] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let env: AppEnvironment
    private var loadTask: Task<Void, Never>?

    init(env: AppEnvironment) {
        self.env = env
    }

    convenience init() {
        self.init(env: .live)
    }

    func loadAvatars() {
        loadTask?.cancel()
        isLoading = true
        errorMessage = nil

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let avatars = try await env.avatarService.getUserAvatars()
                try Task.checkCancellation()
                self.avatars = avatars

                if avatars.isEmpty {
                    errorMessage = "You don't have any avatars yet. Create your first avatar to get started!"
                }

            } catch is CancellationError {
                return
            } catch {
                errorMessage = "Failed to load avatars: \(error.localizedDescription)"
            }

            isLoading = false
        }
    }
}
