//
//  SettingsViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI
import UIKit
import Combine
import UserNotifications
import StoreKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var avatars: [Avatar] = []
    @Published var avatarImage: Image? = nil
    @Published var avatarName: String = "Avail"
    @Published var isAvatarSheetPresented = false

    // Notifications
    @Published var notificationsEnabled: Bool = false

    // Docs
    enum Doc: Identifiable { case terms, privacy
        var id: String { "\(self)" }
        var title: String { self == .terms ? "Terms of Use" : "Privacy Policy" }

        var url: URL? { Self.localHTML(for: self) }

        private static func localHTML(for doc: Doc) -> URL? {
            let name: String
            switch doc {
            case .terms:   name = "terms"
            case .privacy: name = "privacy"
            }
            return Bundle.main.url(forResource: name, withExtension: "html")
        }

        var localFallback: String {
            switch self {
            case .terms: "terms"
            case .privacy: "privacy"
            }
        }
    }
    @Published var presentingDoc: Doc?
    @Published var docs: [Doc] = [.terms, .privacy]

    // Subscriptions
    private var bag = Set<AnyCancellable>()

    init() {
        self.avatars = AvatarLibrary.shared.avatars.map {
            Avatar(id: $0.id, image: $0.image, name: $0.name)
        }

        AvatarLibrary.shared.$avatars
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.avatars = items.map { Avatar(id: $0.id, image: $0.image, name: $0.name) }
            }
            .store(in: &bag)
    }

    // Alerts
    struct SimpleAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    @Published var alert: SimpleAlert?

    // Info
    let accountID: String = SettingsViewModel.loadOrCreateAccountID()
    let appVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String).map { "v\($0)" } ?? "v1.0"

    // MARK: - Actions

    func onRestoreTapped() {
        Task {
            do {
                try await AppStore.sync()
                alert = .init(
                    title: "Purchases Restored",
                    message: "Your App Store purchases have been synchronized."
                )
            } catch {
                alert = .init(
                    title: "Restore Failed",
                    message: error.localizedDescription
                )
            }
        }
    }

    func handleNotificationsToggle(_ on: Bool) {
        guard on else {
            notificationsEnabled = false
            return
        }

        Task {
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .badge, .sound])
                notificationsEnabled = granted
                if !granted {
                    alert = .init(
                        title: "Notifications Disabled",
                        message: "Enable notifications in Settings to receive updates."
                    )
                }
            } catch {
                notificationsEnabled = false
                alert = .init(
                    title: "Notification Error",
                    message: error.localizedDescription
                )
            }
        }
    }

    func openDoc(_ doc: Doc) { presentingDoc = doc }

    // Avatar actions
    func renameAvatar() {
        alert = .init(title: "Rename", message: "Here you can implement rename flow.")
    }
    func changeAvatarPhoto() {
        alert = .init(title: "Change Photo", message: "Open gallery or camera to set new avatar.")
    }
    func deleteAvatar() {
        avatarImage = nil
        avatarName = "Avail"
    }

    // MARK: - Helpers
    private static func loadOrCreateAccountID() -> String {
        let key = "settings.account.id"
        if let v = UserDefaults.standard.string(forKey: key) { return v }
        let v = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        UserDefaults.standard.set(v, forKey: key)
        return v
    }
}
