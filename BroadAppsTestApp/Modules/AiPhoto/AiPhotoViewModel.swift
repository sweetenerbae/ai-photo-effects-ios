//
//  AiPhotoViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI
import PhotosUI
import Combine
import UIKit

final class AiPhotoViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case result(UIImage)
    }
    enum Aspect: CaseIterable {
        case a4x3, a3x2, a16x9, a1x1, a4x5, a2x3, a9x16

        var title: String {
            switch self {
            case .a4x3: return "4:3"
            case .a3x2: return "3:2"
            case .a16x9: return "16:9"
            case .a1x1: return "1:1"
            case .a4x5: return "4:5"
            case .a2x3: return "2:3"
            case .a9x16: return "9:16"
            }
        }
    }

    struct Avatar: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var image: UIImage
    }

    // INPUT
    @Published var prompt: String = ""
    @Published var useAvatar: Bool = false
    @Published var aspect: Aspect = .a4x5
    @Published var state: State = .idle

   @Published var baseImage: UIImage? = nil
   @Published var basePickerItem: PhotosPickerItem?

   @Published private(set) var avatars: [Avatar] = []
   @Published var selectedAvatar: Avatar? {
       didSet {
           avatarThumb = selectedAvatar?.image
           avatarName  = selectedAvatar?.name
           useAvatar   = selectedAvatar != nil
       }
   }
    
    @Published var avatarName: String? = nil
    @Published var avatarThumb: UIImage? = nil
    
    // SHEETS
    enum ActiveSheet: Identifiable {
        case aspect
        case avatar
        var id: String { String(describing: self) }
    }
    @Published var activeSheet: ActiveSheet? = nil

    // nav hooks
    var showBack: Bool = false
    var onBack: (() -> Void)?

    var isPromptValid: Bool { prompt.trimmingCharacters(in: .whitespacesAndNewlines).count >= 5 }
    
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    private let service: ImageGenService
    private let history: HistoryStore

    init(service: ImageGenService, history: HistoryStore) {
        self.service = service
        self.history = history
    }

    // MARK: - Actions

    func generate() {
        guard isPromptValid else { return }
        if case .loading = state { return }

        state = .loading

        Task { @MainActor in
            do {
                let result = try await service.generate(
                    prompt: prompt,
                    avatar: useAvatar ? avatarThumb : nil,
                    aspect: aspect
                )
                state = .result(result)
                history.appendFinished(image: result, prompt: prompt, usedAvatar: useAvatar)
            } catch {
                state = .idle
            }
        }
    }

    func clearResult() { state = .idle }

    func pickAvatar() {
        if let img = UIImage(named: "ob_face_center") {
            avatarThumb = img
            avatarName = "My avatar"
            useAvatar = true
        }
    }
    func createAvatar() { pickAvatar() }
    func removeAvatar() {
        avatarThumb = nil
        avatarName = nil
        useAvatar = false
    }

    // share / save
    func saveToPhotos() {
        guard case .result(let img) = state else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }

    func share() {
        guard case .result(let img) = state else { return }
        let avc = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        UIApplication.shared.firstKeyWindow?.rootViewController?.present(avc, animated: true)
    }
    
    func didPickBasePhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self),
               let img  = UIImage(data: data) {
                baseImage = img
                state = .result(img)
            }
        }
    }

    // MARK: Avatars
    func addAvatar(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self),
               let img  = UIImage(data: data) {
                let name = "Ava\(avatars.count + 1)"
                let av = Avatar(name: name, image: img)
                avatars.append(av)
                selectedAvatar = av
            }
        }
    }

    func deleteSelectedAvatar() {
        guard let sel = selectedAvatar,
              let idx = avatars.firstIndex(of: sel) else { return }
        avatars.remove(at: idx)
        selectedAvatar = nil
    }

}

// helper
private extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? { windows.first(where: { $0.isKeyWindow }) }
}
