//
//  HistoryStore.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import UIKit
import Combine

@MainActor
final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()

    @Published private(set) var items: [HistoryItem] = []
    @Published private(set) var persistenceError: String?

    struct HistoryItem: Identifiable, Equatable, Codable {
        let id: UUID
        let date: Date
        let prompt: String
        let usedAvatar: Bool
        let templateName: String?
        let generationId: String?
        let templatePreview: String?

        var generationStatus: GenerationStatus = .finished

        enum GenerationStatus: String, Codable {
            case generating
            case finished
            case error
        }

        var image: UIImage {
            if let cachedImage = HistoryImageStore.shared.getImage(for: id.uuidString) {
                return cachedImage
            }
            return UIImage(systemName: "photo") ?? UIImage()
        }

        static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
            lhs.id == rhs.id
        }

        var displayName: String {
            if let templateName = templateName, !templateName.isEmpty {
                return templateName
            }
            let words = prompt.split(separator: " ").prefix(3)
            return words.joined(separator: " ") + (prompt.split(separator: " ").count > 3 ? "..." : "")
        }

        enum CodingKeys: String, CodingKey {
           case id, date, prompt, usedAvatar, templateName, generationId, templatePreview, generationStatus
       }
    }

    private init() {
        loadFromStorage()
    }

    // MARK: - Public Methods
    @discardableResult
    func appendGeneratingItem(prompt: String, usedAvatar: Bool = false, templateName: String? = nil, templatePreview: String? = nil, generationId: String) -> HistoryItem {
            let newItem = HistoryItem(
                id: UUID(),
                date: Date(),
                prompt: prompt,
                usedAvatar: usedAvatar,
                templateName: templateName,
                generationId: generationId,
                templatePreview: templatePreview,
                generationStatus: .generating
            )

            items.insert(newItem, at: 0)
            saveToStorage()

            return newItem
        }

    func updateItemStatus(generationId: String, status: HistoryItem.GenerationStatus, resultImage: UIImage? = nil) {
        if let index = items.firstIndex(where: { $0.generationId == generationId }) {
                items[index].generationStatus = status

                // Сохраняем итоговое изображение
                if let resultImage = resultImage, status == .finished {
                    do {
                        try HistoryImageStore.shared.saveImage(
                            resultImage,
                            for: items[index].id.uuidString
                        )
                    } catch {
                        persistenceError = error.localizedDescription
                    }
                }

                saveToStorage()
        }
    }

    func appendFinished(image: UIImage, prompt: String, usedAvatar: Bool, templateName: String? = nil) {
        let newItem = HistoryItem(
            id: UUID(),
            date: Date(),
            prompt: prompt,
            usedAvatar: usedAvatar,
            templateName: templateName,
            generationId: nil,
            templatePreview: nil,
            generationStatus: .finished
        )

        do {
            try HistoryImageStore.shared.saveImage(image, for: newItem.id.uuidString)
        } catch {
            persistenceError = error.localizedDescription
        }

        items.insert(newItem, at: 0)
        saveToStorage()
    }

    func deleteItem(_ item: HistoryItem) {
        // Удаляем изображение из кэша
        do {
            try HistoryImageStore.shared.removeImage(for: item.id.uuidString)
        } catch {
            persistenceError = error.localizedDescription
        }

        items.removeAll { $0.id == item.id }
        saveToStorage()
    }

    func clearAll() {
        // Очищаем весь кэш
        do {
            try HistoryImageStore.shared.clearAll()
        } catch {
            persistenceError = error.localizedDescription
        }

        items.removeAll()
        saveToStorage()
    }

    // MARK: - Private Storage Methods

    private func saveToStorage() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: "history_items")
        } catch {
            persistenceError = error.localizedDescription
        }
    }

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: "history_items") else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let savedItems = try decoder.decode([HistoryItem].self, from: data)

            items = savedItems
        } catch {
            persistenceError = error.localizedDescription
        }
    }
}

final class HistoryImageStore {
    static let shared = HistoryImageStore()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let memoryCache = NSCache<NSString, UIImage>()
    private let lock = NSLock()

    private init() {
        let baseDirectory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory
        cacheDirectory = baseDirectory.appendingPathComponent("HistoryImages", isDirectory: true)
        migrateLegacyImagesIfNeeded()
    }

    func saveImage(_ image: UIImage, for key: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        memoryCache.setObject(image, forKey: key as NSString)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        lock.lock()
        defer { lock.unlock() }
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }

    func getImage(for key: String) -> UIImage? {
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        }
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        lock.lock()
        defer { lock.unlock() }
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        memoryCache.setObject(image, forKey: key as NSString)
        return image
    }

    func removeImage(for key: String) throws {
        memoryCache.removeObject(forKey: key as NSString)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        lock.lock()
        defer { lock.unlock() }
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func clearAll() throws {
        memoryCache.removeAllObjects()
        lock.lock()
        defer { lock.unlock() }
        guard fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        let contents = try fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        )
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }

    private func migrateLegacyImagesIfNeeded() {
        guard let legacyDirectory = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("HistoryImages", isDirectory: true),
        fileManager.fileExists(atPath: legacyDirectory.path),
        let files = try? fileManager.contentsOfDirectory(
            at: legacyDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return
        }

        for source in files {
            let destination = cacheDirectory.appendingPathComponent(source.lastPathComponent)
            guard !fileManager.fileExists(atPath: destination.path) else { continue }
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            try? fileManager.copyItem(at: source, to: destination)
        }
    }
}
