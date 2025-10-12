//
//  CategoryGridView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI

struct CategoryGridView: View {
    let title: String
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<20, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 6) {
                        Image("trend_\((i % 3) + 1)")
                            .resizable().scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        Text(i % 2 == 0 ? "Leggy" : "The professional tennis Player")
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleButton(system: "chevron.left") {
                }
                .disabled(true) 
                .opacity(0)
            }
        }
    }
}
