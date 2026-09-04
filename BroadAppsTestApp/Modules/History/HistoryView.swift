//
//  HistoryView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 14.10.25.
//
import SwiftUI
import Photos

struct HistoryView: View {
    @StateObject private var historyStore = HistoryStore.shared
    @State private var selectedItem: HistoryStore.HistoryItem?
    @State private var showDeleteAlert = false
    @State private var itemToDelete: HistoryStore.HistoryItem?
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.dismiss) private var dismiss

    @State private var showSaveSuccess = false
    @State private var saveSuccessMessage = ""

    private let gridAspectRatio: CGFloat = 0.7

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                if historyStore.items.isEmpty {
                    emptyStateView
                } else {
                    historyGridView
                }

                if showSaveSuccess {
                    saveSuccessToast
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: Binding<Bool>(
               get: { selectedItem != nil },
               set: { if !$0 { selectedItem = nil } }
           )) {
               if let item = selectedItem {
                   HistoryDetailView(item: item)
               }
           }
        }
    }

    // MARK: - Subviews

    private var historyGridView: some View {
          PhotoGridView(
              items: historyStore.items,
              aspectRatio: gridAspectRatio,
              onItemTap: { item in
                  selectedItem = item
              }
          ) { item in
              HistoryGridItemView(item: item)
                  .contextMenu {
                      if item.generationStatus == .finished {
                          Button {
                              saveToPhotos(item: item)
                          } label: {
                              Label("Save to Photos", systemImage: "square.and.arrow.down")
                          }

                          Button {
                              shareItem(item: item)
                          } label: {
                              Label("Share", systemImage: "square.and.arrow.up")
                          }

                          Divider()

                          Button(role: .destructive) {
                              itemToDelete = item
                          } label: {
                              Label("Delete", systemImage: "trash")
                          }
                      }
                }
          }
          .deleteAlert(
              item: $itemToDelete,
              itemName: "image"
          ) { item in
              historyStore.deleteItem(item)
          } onDismiss: {
              dismiss()
          }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(Color.primaryOrange)

            Text("It's empty now")
                .appFont(.title)
                .foregroundStyle(Color.labelBlack)

            Button {
                tabRouter.selected = .effects
            } label: {
                Text("Create First Photo")
                    .appFont(.button)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.labelBlack)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .background(Color.grayButton)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
    }

    private var saveSuccessToast: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(saveSuccessMessage)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 10)
            .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: showSaveSuccess)
    }

    // MARK: - Actions
    private func saveToPhotos(item: HistoryStore.HistoryItem) {
        Task { @MainActor in
            var status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            if status == .notDetermined {
                status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            }

            guard status == .authorized || status == .limited else {
                    showSaveSuccess(message: "Please allow photo access in Settings")
                return
            }

            do {
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: item.image)
                }
                showSaveSuccess(message: "Image saved to Photos!")
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                showSaveSuccess(message: "Unable to save the image")
            }
        }
    }

    private func shareItem(item: HistoryStore.HistoryItem) {
        let activityVC = UIActivityViewController(
            activityItems: [item.image],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootVC.present(activityVC, animated: true)
        }
    }

    private func showSaveSuccess(message: String) {
        saveSuccessMessage = message
        showSaveSuccess = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation {
                showSaveSuccess = false
            }
        }
    }
}

#Preview {
    HistoryView()
}
