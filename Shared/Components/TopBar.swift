//
//  TopBar.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI

struct TopBar<Leading: View, Trailing: View>: View {
    let title: String
    var titleFont: Font = .system(size: 18, weight: .semibold)
    var height: CGFloat = 56
    var contentPadding: CGFloat = 16
    var background: Color = Color.white

    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        ZStack {
            background.ignoresSafeArea(edges: .top)

            HStack {
                leading()
                    .frame(width: 48, height: 48, alignment: .center)
                Spacer()
                trailing()
                    .frame(width: 48, height: 48, alignment: .center)
            }
            .padding(.horizontal, contentPadding)

            Text(title)
                .font(titleFont)
                .foregroundStyle(.labelBlack)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, contentPadding + 64)
        }
        .frame(height: height)
    }
}
