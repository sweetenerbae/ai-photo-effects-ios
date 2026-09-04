//
//  HistoryGridItemView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 18.10.25.
//

import SwiftUI

struct HistoryGridItemView: View {
    let item: HistoryStore.HistoryItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Фон и изображение в зависимости от статуса
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))
                .overlay(contentOverlay)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            // Градиент для текста
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .allowsHitTesting(false)

            // Текст
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(statusText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)

            // Иконка аватара если использовался
            if item.usedAvatar {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .allowsHitTesting(item.generationStatus == .finished)
    }

    // MARK: - Content Overlay
    private var contentOverlay: some View {
        Group {
            switch item.generationStatus {
            case .generating:
                generatingOverlay
            case .finished:
                finishedOverlay
            case .error:
                errorOverlay
            }
        }
    }

    private var generatingOverlay: some View {
        ZStack {
            // Показываем превью шаблона если есть
            if let templatePreview = item.templatePreview {
                AsyncThumb(urlString: templatePreview)
                    .scaledToFill()
                    .opacity(0.3)
            } else {
                Color.gray.opacity(0.3)
            }

            // Индикатор загрузки
            VStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                Text("Wait for the generation\nto finish")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var finishedOverlay: some View {
        Group {
            Image(uiImage: item.image)
                .resizable()
                .scaledToFill()
        }
    }

    private var errorOverlay: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundColor(.orange)

            Text("Generation failed")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
    }

    // MARK: - Status Text
    private var statusText: String {
        switch item.generationStatus {
        case .generating:
            return "Generating..."
        case .finished:
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: item.date, relativeTo: Date())
        case .error:
            return "Failed"
        }
    }

}

// MARK: - Extension для отображения заголовка
extension HistoryStore.HistoryItem {
    var displayTitle: String {
        if let templateName = templateName, !templateName.isEmpty {
            return templateName
        }
        // первые 2-3 слова из промпта для компактности
        let words = prompt.split(separator: " ").prefix(2)
        return words.joined(separator: " ") + (prompt.split(separator: " ").count > 2 ? "..." : "")
    }
}
