//
//  ActionButton.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI

struct ActionButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .appFont(.body)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:   return Color.primaryOrange
        case .secondary: return Color.grayButton
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:   return .white
        case .secondary: return .primary
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:   return .clear
        case .secondary: return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .primary:   return 0
        case .secondary: return 0
        }
    }
}
