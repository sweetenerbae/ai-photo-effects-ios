import Foundation
import UIKit

protocol AvatarServicing {
    func createAvatar(gender: String, title: String?, photos: [UIImage]) async throws -> GenerationReadDTO
    func deleteAvatar(avatarId: Int) async throws
    func getUserAvatars() async throws -> [FotobudkaAvatar]
    func getAvatarDetail(avatarId: Int) async throws -> FotobudkaAvatar
    func setAvatarPreview(avatarId: Int, previewImage: UIImage) async throws -> [FotobudkaAvatar]
    func getGenerationStatus(generationId: String) async throws -> GenerationReadDTO
    func loadAvatarImage(from urlString: String?) async -> UIImage?
}

enum AvatarServiceError: LocalizedError {
    case avatarNotFound
    case imageEncodingFailed
    case noValidPhotos

    var errorDescription: String? {
        switch self {
        case .avatarNotFound:
            return "Avatar not found."
        case .imageEncodingFailed:
            return "The selected image could not be prepared for upload."
        case .noValidPhotos:
            return "None of the selected photos could be prepared for upload."
        }
    }
}

final class AvatarService: AvatarServicing {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func createAvatar(
        gender: String,
        title: String?,
        photos: [UIImage]
    ) async throws -> GenerationReadDTO {
        if AppConfig.isPortfolioMode {
            return GenerationReadDTO(
                id: UUID().uuidString,
                type: "portfolio_avatar_generation",
                status: "started",
                result: "9001",
                error: nil
            )
        }

        let files = photos.enumerated().compactMap { index, image -> MultipartFile? in
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            return MultipartFile(
                data: data,
                fieldName: "photos",
                fileName: "photo_\(index).jpg",
                mimeType: "image/jpeg"
            )
        }
        guard !files.isEmpty else {
            throw AvatarServiceError.noValidPhotos
        }

        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let parameters = trimmedTitle.flatMap { $0.isEmpty ? nil : ["title": $0] } ?? [:]

        return try await networkClient.uploadMultipart(
            "/api/generations/fotobudka/avatar",
            query: [URLQueryItem(name: "gender", value: gender)],
            parameters: parameters,
            files: files
        )
    }

    func deleteAvatar(avatarId: Int) async throws {
        guard !AppConfig.isPortfolioMode else { return }
        try await networkClient.request(
            "/api/generations/fotobudka/avatar/\(avatarId)",
            method: .DELETE
        )
    }

    func getUserAvatars() async throws -> [FotobudkaAvatar] {
        if AppConfig.isPortfolioMode {
            return PortfolioDemoData.demoAvatars
        }
        return try await networkClient.get("/api/generations/fotobudka/avatar")
    }

    func loadAvatarImage(from urlString: String?) async -> UIImage? {
        guard let urlString else { return nil }
        if let assetName = PortfolioDemoData.assetName(from: urlString) {
            return PortfolioDemoData.makePreviewImage(named: assetName)
        }
        guard let url = URLResolver.absolute(urlString) else { return nil }

        do {
            let data = try await networkClient.download(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    func getAvatarDetail(avatarId: Int) async throws -> FotobudkaAvatar {
        let avatars = try await getUserAvatars()
        guard let avatar = avatars.first(where: { $0.id == avatarId }) else {
            throw AvatarServiceError.avatarNotFound
        }
        return avatar
    }

    func setAvatarPreview(
        avatarId: Int,
        previewImage: UIImage
    ) async throws -> [FotobudkaAvatar] {
        if AppConfig.isPortfolioMode {
            return PortfolioDemoData.demoAvatars
        }
        guard let data = previewImage.jpegData(compressionQuality: 0.8) else {
            throw AvatarServiceError.imageEncodingFailed
        }

        return try await networkClient.uploadMultipart(
            "/api/generations/fotobudka/avatar/\(avatarId)/preview",
            files: [
                MultipartFile(
                    data: data,
                    fieldName: "preview",
                    fileName: "preview.jpg",
                    mimeType: "image/jpeg"
                )
            ]
        )
    }

    func getGenerationStatus(generationId: String) async throws -> GenerationReadDTO {
        if AppConfig.isPortfolioMode {
            return GenerationReadDTO(
                id: generationId,
                type: "portfolio_avatar_generation",
                status: "finished",
                result: "9001",
                error: nil
            )
        }
        return try await networkClient.get("/api/generations/\(generationId)")
    }
}
