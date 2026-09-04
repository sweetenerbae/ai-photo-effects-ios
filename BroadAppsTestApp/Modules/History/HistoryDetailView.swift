//
//  HistoryDetailView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 18.10.25.
//

import SwiftUI

struct HistoryDetailView: View {
    @StateObject private var historyStore = HistoryStore.shared
    @StateObject private var vm: HistoryDetailViewModel
    @State private var itemToDelete: HistoryStore.HistoryItem?
    @Environment(\.dismiss) private var dismiss

    init(item: HistoryStore.HistoryItem) {
        _vm = StateObject(wrappedValue: HistoryDetailViewModel(item: item))
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                title: "Effects",
                leading: {
                    CircleButton(
                        system: "chevron.left",
                        action: { dismiss() },
                        style: .gray
                    )
                },
                trailing: {
                    Color.clear
                }
            )

            contentView

            actionsView
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .deleteAlert(
            item: $itemToDelete,
            itemName: "image"
        ) { item in
            historyStore.deleteItem(item)
            dismiss()
        }
        .overlay {
            if vm.showSaveSuccess {
                saveSuccessToast
            }
        }
        .overlay {
            if vm.isSaving {
                savingOverlay
            }
        }
        .alert(item: $vm.alert) { alert in
            if alert.offersSettings {
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    primaryButton: .default(Text("Settings"), action: vm.openSettings),
                    secondaryButton: .cancel()
                )
            } else {
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Subviews (без изменений)

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(uiImage: vm.item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 20)
        }
    }
    private var actionsView: some View {
        ImageActionsView(
            onDownload: { vm.saveToPhotos() },
            onShare: { vm.share() },
            onRemove: { itemToDelete = vm.item },
            isSaving: vm.isSaving,
            showRemove: true
        )
    }

    private var saveSuccessToast: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Saved to Photos!")
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 10)
            .padding()
        }
        .transition(.move(edge: .bottom))
        .animation(.spring(), value: vm.showSaveSuccess)
    }

    private var savingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Saving to Photos...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 10)
        }
    }
}
