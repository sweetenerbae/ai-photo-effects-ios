//
//  PaywallView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 15.10.25.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = PaywallViewModel()
    @State private var presentedDocument: SettingsViewModel.Doc?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Color.primaryOrange
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        .overlay(StarsStrip(), alignment: .bottom)
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                    }
                    .padding(16)
                }

                // Белая карточка
                VStack(spacing: 16) {
                    PlanRow(plan: .weekly, selected: $vm.selected)
                    PlanRow(plan: .monthly, selected: $vm.selected)
                    PlanRow(plan: .monthlyDiscount, selected: $vm.selected)

                    HStack(spacing: 6) {
                        Circle().fill(Color.secondary.opacity(0.3))
                            .frame(width: 6, height: 6)
                        Text("Cancel at any time")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)

                    Button {
                        Task {
                            if await vm.continueTapped() {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primaryOrange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }
                    .disabled(vm.isPurchasing)
                    .opacity(vm.isPurchasing ? 0.6 : 1.0)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .shadow(radius: 8, y: 2)
                )
                .padding(.horizontal, 16)
                .offset(y: -32)

                // Нижние ссылки
                HStack {
                    Button("Privacy Policy") { openLocal(.privacy) }
                        .buttonStyle(.plain)
                    Spacer()
                    Button("Recover") {
                        Task { await vm.restore() }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button("Terms of Use") { openLocal(.terms) }
                        .buttonStyle(.plain)
                }
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer(minLength: 12)
            }
        }
        .onAppear { vm.onAppear() }
        .sheet(item: $presentedDocument) { document in
            WebDocumentView(doc: document)
        }
        .alert(
            "Subscription Error",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
    }

    private func openLocal(_ doc: SettingsViewModel.Doc) {
        presentedDocument = doc
    }
}

private struct PlanRow: View {
    let plan: PaywallViewModel.Plan
    @Binding var selected: PaywallViewModel.Plan

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selected = plan
        } label: {
            HStack(spacing: 12) {
                // radio
                ZStack {
                    Circle().stroke(selected == plan ? Color.primaryOrange : .secondary, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if selected == plan {
                        Circle().fill(Color.primaryOrange).frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title).font(.system(size: 16, weight: .semibold))
                    if !plan.subtitle.isEmpty {
                        Text(plan.subtitle).font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let badge = plan.badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.vertical, 6).padding(.horizontal, 8)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }

                Text(plan.priceText).font(.system(size: 16, weight: .semibold))
            }
            .padding(14)
            .background(Color.grayButton)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// чисто декоративная полоса
private struct StarsStrip: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.25)).frame(width: 8, height: 8)
            RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.25)).frame(width: 12, height: 12)
            RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.25)).frame(width: 8, height: 8)
        }
        .padding(.bottom, 8)
    }
}
