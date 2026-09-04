//
//  CategoryGridView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI

struct CategoryGridView: View {
    let title: String
    let templates: [PhotoStyle]

    private let cols = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(templates) { tmpl in
                    NavigationLink(
                        value: EffectCreationRoute(
                            templateId: tmpl.id,
                            categoryTitle: title
                        )
                    ) {
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.15))
                                .aspectRatio(0.7, contentMode: .fit)
                                .overlay(AsyncThumb(urlString: tmpl.displayPreview))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                            LinearGradient(colors: [.clear, .black.opacity(0.55)],
                                           startPoint: .top, endPoint: .bottom)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .allowsHitTesting(false)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
