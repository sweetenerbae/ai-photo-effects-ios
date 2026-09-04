import Combine
import Photos
import SwiftUI

@MainActor
final class HistoryDetailViewModel: ObservableObject {
    struct AlertState: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let offersSettings: Bool
    }

    let item: HistoryStore.HistoryItem

    @Published private(set) var showSaveSuccess = false
    @Published private(set) var isSaving = false
    @Published var alert: AlertState?

    init(item: HistoryStore.HistoryItem) {
        self.item = item
    }

    func saveToPhotos() {
        guard !isSaving else { return }
        isSaving = true

        Task { [weak self] in
            guard let self else { return }
            let status = await photoAuthorizationStatus()
            guard status == .authorized || status == .limited else {
                isSaving = false
                alert = AlertState(
                    title: "Photo Access Required",
                    message: "Allow photo access in Settings to save images.",
                    offersSettings: status == .denied
                )
                return
            }

            do {
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: self.item.image)
                }
                isSaving = false
                showSaveSuccess = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                try await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveSuccess = false
            } catch is CancellationError {
                isSaving = false
            } catch {
                isSaving = false
                alert = AlertState(
                    title: "Save Failed",
                    message: error.localizedDescription,
                    offersSettings: false
                )
            }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func share() {
        let activityController = UIActivityViewController(
            activityItems: [item.image],
            applicationActivities: nil
        )
        guard let presenter = UIApplication.shared.topViewController else { return }

        if let popover = activityController.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        presenter.present(activityController, animated: true)
    }

    private func photoAuthorizationStatus() async -> PHAuthorizationStatus {
        let current = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        guard current == .notDetermined else { return current }
        return await PHPhotoLibrary.requestAuthorization(for: .addOnly)
    }
}

private extension UIApplication {
    var topViewController: UIViewController? {
        guard
            let scene = connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
            let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController
        else {
            return nil
        }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
