import Foundation
import UIKit

final class RealImageGenService: ImageGenService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func generate(
        prompt: String,
        avatar: UIImage?,
        aspect: AiPhotoViewModel.Aspect,
        template: PhotoStyle?
    ) async throws -> UIImage {
        if AppConfig.isPortfolioMode {
            try await Task.sleep(nanoseconds: 800_000_000)
            return avatar ?? PortfolioDemoData.makePreviewImage(named: "ob_face_center")
        }

        // The current backend endpoint accepts prompt and template only.
        _ = avatar
        _ = aspect

        let generationId = try await startGeneration(
            prompt: prompt,
            templateId: template?.id
        )
        let imageURL = try await waitForCompletion(generationId: generationId)
        return try await downloadImage(from: imageURL)
    }

    private func startGeneration(prompt: String, templateId: Int?) async throws -> String {
        let request = GenerationRequest(prompt: prompt, templateId: templateId)
        let response: GenerationReadDTO = try await networkClient.post(
            "/api/generations/fotobudka/txt2img",
            body: request
        )
        return response.id
    }

    private func waitForCompletion(generationId: String) async throws -> URL {
        for _ in 0..<30 {
            try Task.checkCancellation()
            let generation: GenerationReadDTO = try await networkClient.get(
                "/api/generations/\(generationId)"
            )

            switch generation.status.lowercased() {
            case "finished":
                guard let url = URLResolver.absolute(generation.result) else {
                    throw ImageGenError.invalidImageURL
                }
                return url
            case "error", "failed":
                throw ImageGenError.generationFailed(
                    generation.error ?? "The server did not provide an error message."
                )
            case "queued", "started", "processing":
                try await Task.sleep(nanoseconds: 2_000_000_000)
            default:
                throw ImageGenError.unknownStatus(generation.status)
            }
        }
        throw ImageGenError.timeout
    }

    private func downloadImage(from url: URL) async throws -> UIImage {
        let data = try await networkClient.download(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageGenError.invalidImageData
        }
        return image
    }
}

enum ImageGenError: LocalizedError {
    case generationFailed(String)
    case unknownStatus(String)
    case timeout
    case invalidImageURL
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return "Generation failed: \(message)"
        case .unknownStatus(let status):
            return "Unknown generation status: \(status)"
        case .timeout:
            return "Generation took too long. Please try again."
        case .invalidImageURL:
            return "The server returned an invalid image URL."
        case .invalidImageData:
            return "The downloaded file is not a valid image."
        }
    }
}
