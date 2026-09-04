import Combine
import PhotosUI
import SwiftUI

@MainActor
final class AvatarCreationViewModel: ObservableObject {
    enum Step {
        case gender, name, photos, progress, preview
    }

    enum Gender: String {
        case woman = "f"
        case man = "m"
    }

    @Published var step: Step = .gender
    @Published var gender: Gender?
    @Published var pickedItems: [PhotosPickerItem] = []
    @Published var images: [UIImage] = []
    @Published private(set) var loading = false
    @Published private(set) var error: String?
    @Published var shouldDismiss = false
    @Published var avatarName = ""
    @Published private(set) var generatedImage: UIImage?
    @Published private(set) var generationId: String?
    @Published private(set) var generationStatus: String?
    @Published private(set) var createdAvatar: FotobudkaAvatar?

    private let avatarService: AvatarServicing
    private let history: HistoryStore
    private let avatarLibrary: AvatarLibrary
    private var generationTask: Task<Void, Never>?
    private var photoLoadingTask: Task<Void, Never>?

    init(
        avatarService: AvatarServicing,
        history: HistoryStore,
        avatarLibrary: AvatarLibrary
    ) {
        self.avatarService = avatarService
        self.history = history
        self.avatarLibrary = avatarLibrary
    }

    convenience init() {
        self.init(
            avatarService: AppEnvironment.live.avatarService,
            history: .shared,
            avatarLibrary: .shared
        )
    }

    var canContinueGender: Bool { gender != nil }
    var canContinuePhotos: Bool { (10...50).contains(images.count) }
    var canContinueName: Bool {
        avatarName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    func goNext() {
        switch step {
        case .gender where canContinueGender:
            step = .name
        case .name where canContinueName:
            step = .photos
        case .photos where canContinuePhotos:
            startGeneration()
        case .gender, .name, .photos, .progress, .preview:
            break
        }
    }

    func startGeneration() {
        guard let gender, canContinuePhotos else {
            error = "Select a gender and between 10 and 50 photos."
            return
        }

        generationTask?.cancel()
        error = nil
        loading = true
        step = .progress
        generationStatus = "queued"

        let photos = images
        let trimmedName = avatarName.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = trimmedName.isEmpty ? "My Avatar" : trimmedName

        generationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let generation = try await avatarService.createAvatar(
                    gender: gender.rawValue,
                    title: title,
                    photos: photos
                )
                generationId = generation.id
                generationStatus = generation.status

                let completed = try await waitForCompletion(
                    initial: generation,
                    maximumAttempts: 40
                )
                try await applyCompletedGeneration(completed, fallbackImage: photos.first)
            } catch is CancellationError {
                loading = false
            } catch {
                loading = false
                generationStatus = "error"
                self.error = error.localizedDescription
                step = .photos
            }
        }
    }

    func convertPicked() {
        photoLoadingTask?.cancel()
        let selection = Array(pickedItems.prefix(50))

        photoLoadingTask = Task { [weak self] in
            var loadedImages: [UIImage] = []
            for item in selection {
                guard !Task.isCancelled else { return }
                guard
                    let data = try? await item.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                else {
                    continue
                }
                loadedImages.append(image)
            }
            guard !Task.isCancelled else { return }
            self?.images = loadedImages
            if loadedImages.isEmpty, !selection.isEmpty {
                self?.error = "The selected photos could not be loaded."
            }
        }
    }

    func removeImage(_ image: UIImage) {
        images.removeAll { $0 === image }
    }

    func regenerate() {
        generationId = nil
        generationStatus = nil
        createdAvatar = nil
        generatedImage = nil
        startGeneration()
    }

    func finish() {
        generationTask?.cancel()

        if let generatedImage {
            let name = avatarName.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalName = name.isEmpty ? "My Avatar" : name
            avatarLibrary.add(name: finalName, image: generatedImage)
            history.appendFinished(
                image: generatedImage,
                prompt: "[Avatar \(finalName)]",
                usedAvatar: true
            )
        }
        shouldDismiss = true
    }

    private func waitForCompletion(
        initial: GenerationReadDTO,
        maximumAttempts: Int
    ) async throws -> GenerationReadDTO {
        var generation = initial

        for attempt in 0..<maximumAttempts {
            try Task.checkCancellation()
            switch generation.status.lowercased() {
            case "finished":
                return generation
            case "error", "failed":
                throw AvatarCreationError.generationFailed(generation.error)
            case "queued", "started", "processing":
                guard attempt < maximumAttempts - 1 else { break }
                try await Task.sleep(nanoseconds: 3_000_000_000)
                generation = try await avatarService.getGenerationStatus(
                    generationId: generation.id
                )
                generationStatus = generation.status
            default:
                throw AvatarCreationError.unknownStatus(generation.status)
            }
        }
        throw AvatarCreationError.timeout
    }

    private func applyCompletedGeneration(
        _ generation: GenerationReadDTO,
        fallbackImage: UIImage?
    ) async throws {
        guard let result = generation.result, let avatarId = Int(result) else {
            throw AvatarCreationError.missingAvatarId
        }

        let avatar = try await avatarService.getAvatarDetail(avatarId: avatarId)
        let remoteImage = await avatarService.loadAvatarImage(from: avatar.preview)
        guard let image = remoteImage ?? fallbackImage else {
            throw AvatarCreationError.missingPreview
        }

        createdAvatar = avatar
        generatedImage = image
        generationStatus = "finished"
        loading = false
        step = .preview
    }
}

private enum AvatarCreationError: LocalizedError {
    case generationFailed(String?)
    case unknownStatus(String)
    case missingAvatarId
    case missingPreview
    case timeout

    var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return message ?? "Avatar generation failed. Please try again."
        case .unknownStatus(let status):
            return "Unknown avatar generation status: \(status)"
        case .missingAvatarId:
            return "The server did not return the created avatar identifier."
        case .missingPreview:
            return "The avatar was created, but its preview is not available yet."
        case .timeout:
            return "Avatar generation is taking longer than expected. Please try again later."
        }
    }
}
