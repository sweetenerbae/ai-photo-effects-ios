//
//  SettingsViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI
import Combine
import UserNotifications
import StoreKit

final class SettingsViewModel: ObservableObject {
    // Avatar
    @Published var avatarImage: Image? = nil
    @Published var avatarName: String = "Avail"
    @Published var isAvatarSheetPresented = false

    // Notifications
    @Published var notificationsEnabled: Bool = false

    // Docs
    enum Doc: Identifiable { case terms, privacy
        var id: String { "\(self)" }
        var title: String { self == .terms ? "Terms of Use" : "Privacy Policy" }
        var url: URL { // твои ссылки
            switch self {
            case .terms:   return URL(string: "https://example.com/terms")!
            case .privacy: return URL(string: "https://example.com/privacy")!
            }
        }
        var localFallback: String { // имена локальных HTML в бандле
            switch self {
            case .terms: "terms"
            case .privacy: "privacy"
            }
        }
    }
    @Published var presentingDoc: Doc?

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
        // Заглушка восстановления покупок: покажем алерт
        alert = .init(title: "Restore Purchases", message: "Renew your sub — вызывает восстановление покупок.")
        // Task { try? await AppStore.sync() } // StoreKit 2
    }

    func handleNotificationsToggle(_ on: Bool) {
        if on {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                DispatchQueue.main.async {
                    self.notificationsEnabled = granted
                    if !granted {
                        self.alert = .init(title: "Notifications disabled",
                                           message: "Enable notifications in Settings to receive updates.")
                    }
                }
            }
        } else {
            // Пользователь выключил в приложении
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
