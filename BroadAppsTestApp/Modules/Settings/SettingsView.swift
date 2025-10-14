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
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {

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

                                Divider()
                                    .padding(.leading, 48)
                                    .padding(.vertical, 6)

                                SettingRow(
                                    icon: "arrow.clockwise",
                                    title: "Renew your subscription",
                                    trailing: .chevron
                                ) { vm.onRestoreTapped() }
                            }
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .background(Color.grayButton)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .groupBoxStyle(PlainGroupBoxStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)

                        // MARK: Notifications
                        GroupBox {
                            HStack(spacing: 12) {
                                IconTile(name: "bell.fill")
                                Text("Notifications")
                                    .appFont(.body)
                                Spacer()
                                Toggle("", isOn: $vm.notificationsEnabled)
                                    .labelsHidden()
                                    .onChange(of: vm.notificationsEnabled) {_, on in
                                        vm.handleNotificationsToggle(on)
                                    }
                            }
                            .frame(minHeight: 44)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.grayButton)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .groupBoxStyle(PlainGroupBoxStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)

                        // MARK: Legal
                        GroupBox {
                            VStack(spacing: 0) {
                                SettingRow(
                                    icon: "doc.text.fill",
                                    title: "Terms of Use",
                                    trailing: .chevron
                                ) { vm.openDoc(.terms) }

                                Divider()
                                    .padding(.leading, 48)
                                    .padding(.vertical, 6)

                                SettingRow(
                                    icon: "shield.fill",
                                    title: "Privacy Policy",
                                    trailing: .chevron
                                ) { vm.openDoc(.privacy) }
                            }
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .background(Color.grayButton)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .groupBoxStyle(PlainGroupBoxStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 2)

                        // Push footer to the bottom if content is short
                        Spacer(minLength: 0)

                        // MARK: App Info
                        VStack(alignment: .leading, spacing: 8) {
                            Divider()
                                .padding(.horizontal, 16)
                            InfoRow(label: "Account ID", value: vm.accountID)
                            InfoRow(label: "Version", value: vm.appVersion)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .frame(minHeight: geo.size.height, alignment: .top)
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $vm.isAvatarSheetPresented) {
                AvatarCreationFlowView()
                    .ignoresSafeArea()
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
                .background(Color.grayButton)
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
                    .appFont(.body)
                    .foregroundStyle(.primary)
                Spacer()
                if trailing == .chevron {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

private struct IconTile: View {
    let name: String
    var body: some View {
        ZStack {
            Image(systemName: name)
                .foregroundStyle(.black)
        }
        .frame(width: 20, height: 20)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.gray)
                .font(.system(size: 12, weight: .medium))
            Spacer()
            Text(value)
                .foregroundStyle(Color.gray)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.vertical, 6)
    }
}

// Lightweight GroupBox style (no extra chrome)
private struct PlainGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}

#Preview {
    SettingsView()
}
