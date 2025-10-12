//
//  SettingsView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {

                    // MARK: Profile / Avatar
                    AvatarHeader(
                        image: vm.avatarImage,
                        name: vm.avatarName,
                        onTap: { vm.isAvatarSheetPresented = true }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // MARK: Subscription
                    GroupBox {
                        VStack(spacing: 0) {
                            SettingRow(
                                icon: "diamond.fill",
                                title: "Renew your subscription",
                                trailing: .chevron
                            ) { vm.onRestoreTapped() }

                            Divider().padding(.leading, 48)

                            SettingRow(
                                icon: "arrow.clockwise",
                                title: "Renew your subscription",
                                trailing: .chevron
                            ) { vm.onRestoreTapped() }
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 16)

                    // MARK: Notifications
                    GroupBox {
                        HStack(spacing: 12) {
                            IconTile(name: "bell.fill")
                            Text("Notifications")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                            Toggle("", isOn: $vm.notificationsEnabled)
                                .labelsHidden()
                                .onChange(of: vm.notificationsEnabled) { on in
                                    vm.handleNotificationsToggle(on)
                                }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 16)

                    // MARK: Legal
                    GroupBox {
                        VStack(spacing: 0) {
                            SettingRow(
                                icon: "doc.text.fill",
                                title: "Terms of Use",
                                trailing: .chevron
                            ) { vm.openDoc(.terms) }

                            Divider().padding(.leading, 48)

                            SettingRow(
                                icon: "shield.fill",
                                title: "Privacy Policy",
                                trailing: .chevron
                            ) { vm.openDoc(.privacy) }
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 16)

                    // MARK: App Info
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "Account ID", value: vm.accountID)
                        InfoRow(label: "Version", value: vm.appVersion)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $vm.isAvatarSheetPresented) {
                AvatarActionsSheet(
                    name: vm.avatarName,
                    onRename: vm.renameAvatar,
                    onChangePhoto: vm.changeAvatarPhoto,
                    onDelete: vm.deleteAvatar
                )
                .presentationDetents([.medium])
            }
            .sheet(item: $vm.presentingDoc) { doc in
                WebDocumentView(doc: doc)
            }
            .alert(item: $vm.alert) { a in
                Alert(title: Text(a.title), message: Text(a.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - UI pieces

private struct AvatarHeader: View {
    let image: Image?
    let name: String
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Button(action: onTap) {
                ZStack {
                    if let image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(width: 84, height: 84)
                .background(Color(.systemGray6))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Add an avatar")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text(name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
    }
}

private struct SettingRow: View {
    enum Trailing { case chevron, none }
    let icon: String
    let title: String
    let trailing: Trailing
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconTile(name: icon)
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                if trailing == .chevron {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
    }
}

private struct IconTile: View {
    let name: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemGray5))
            Image(systemName: name)
                .foregroundStyle(.black)
        }
        .frame(width: 28, height: 28)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    SettingsView()
}
