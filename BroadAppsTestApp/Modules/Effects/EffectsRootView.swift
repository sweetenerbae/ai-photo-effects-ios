//
//  EffectsRootView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//
import SwiftUI

struct EffectsRootView: View {
    private let cardW = min(UIScreen.main.bounds.width * 0.36, 170)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    SectionHeaderRow(title: "Trends", route: "category_trends")
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<8, id: \.self) { i in
                                EffectCard(
                                    image: "effects\(i % 3 + 1)",
                                    title: sampleTitles[i % sampleTitles.count],
                                    width: cardW
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    SectionHeaderRow(title: "Dolls", route: "category_dolls")
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<8, id: \.self) { i in
                                EffectCard(
                                    image: "doll_\(i % 3 + 1)",
                                    title: "Leggy",
                                    width: cardW
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 12)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { route in
                switch route {
                case "category_trends":
                    CategoryGridView(title: "Trends")
                case "category_dolls":
                    CategoryGridView(title: "Dolls")
                default:
                    EmptyView()
                }
            }
        }
    }

    private let sampleTitles = [
        "Leggy", "The professional tennis Player", "Pro tennis player"
    ]
}

private struct SectionHeaderRow: View {
    let title: String
    let route: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold))
            Spacer()
            NavigationLink(value: route) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

private struct EffectCard: View {
    let image: String
    let title: String
    let width: CGFloat
    var height: CGFloat { width / 0.7 }

    private let corner: CGFloat = 16

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))

            LinearGradient(colors: [.clear, .black.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: height * 0.35)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .allowsHitTesting(false)

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
        }
        .frame(width: width, height: height, alignment: .bottomLeading)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}
