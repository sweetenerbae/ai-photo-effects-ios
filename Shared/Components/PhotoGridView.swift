//
//  PhotoGridView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 18.10.25.
//
import SwiftUI

struct PhotoGridView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let columns: [GridItem]
    let spacing: CGFloat
    let padding: CGFloat
    let aspectRatio: CGFloat
    let onItemTap: (Item) -> Void
    let content: (Item) -> Content

    init(
        items: [Item],
        columns: [GridItem] = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ],
        spacing: CGFloat = 12,
        padding: CGFloat = 16,
        aspectRatio: CGFloat = 0.7,
        onItemTap: @escaping (Item) -> Void,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.spacing = spacing
        self.padding = padding
        self.aspectRatio = aspectRatio
        self.onItemTap = onItemTap
        self.content = content
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(items) { item in
                    content(item)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .onTapGesture {
                            onItemTap(item)
                        }
                }
            }
            .padding(padding)
        }
    }
}
