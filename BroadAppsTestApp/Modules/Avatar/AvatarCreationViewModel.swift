//
//  AvatarCreationViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 13.10.25.
//

import SwiftUI
import PhotosUI
import Combine

final class AvatarCreationViewModel: ObservableObject {
    enum Step { case gender, name, photos, progress, preview }
    enum Gender: String { case woman, man }

    @Published var step: Step = .gender
    @Published var gender: Gender? = nil

    @Published var pickedItems: [PhotosPickerItem] = []
    @Published var images: [UIImage] = []
    @Published var loading: Bool = false
    @Published var error: String? = nil
    @Published var shouldDismiss = false
    
    @Published var avatarName: String = ""
    @Published var generatedImage: UIImage? = nil

    // Валидации
    var canContinueGender: Bool { gender != nil }
    var canContinuePhotos: Bool { images.count >= 10 && images.count <= 50 }
    var canContinueName:   Bool { avatarName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 }

    // MARK: actions
    func goNext() {
        switch step {
        case .gender:
            step = .name
        case .name:
            step = .photos
        case .photos:
            startGeneration()
        case .progress:
            break
        case .preview:
            break
        }
    }

    func startGeneration() {
        step = .progress
        loading = true
        // Заглушка генерации (для App Store)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            // первую валидную фотку как результирующую
            self.generatedImage = self.images.first
            self.loading = false
            self.step = .preview
        }
    }

    func convertPicked() {
        images.removeAll()
        Task { @MainActor in
            for item in pickedItems.prefix(50) {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    images.append(img)
                }
            }
        }
    }

    func removeImage(_ img: UIImage) {
        images.removeAll { $0 == img }
    }

    // повторная генерация из экрана готового аватара
    func regenerate() {
        startGeneration()
    }

    func finish() {
        if let img = generatedImage {
            let name = avatarName.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalName = name.isEmpty ? "My Avatar" : name

            // сохраняем аватар в библиотеку
            AvatarLibrary.shared.add(name: finalName, image: img)

            // кидаем запись в историю (стаб-промпт для ревью)
            HistoryStore.shared.appendFinished(
                image: img,
                prompt: "[Avatar \(finalName)]",
                usedAvatar: true
            )
        }

        shouldDismiss = true
    }
}
