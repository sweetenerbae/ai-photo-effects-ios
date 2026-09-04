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
    let iconName: String?

    init(title: String, style: Style, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
        self.iconName = nil
    }

    init(title: String, style: Style, iconName: String?, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
        self.iconName = iconName
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(iconName)
                        .resizable()
                        .frame(width: 24, height: 24)
                }

                Text(title)
                    .appFont(.body)
            }
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
}
