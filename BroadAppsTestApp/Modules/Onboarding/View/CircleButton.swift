//
//  CirleButton.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//

import SwiftUI

struct CircleButton: View {
    enum Style {
        case white
        case gray
    }

    let system: String
    let action: () -> Void
    var style: Style = .white
    var size: CGFloat = 48

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundStyle(.labelBlack)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch style {
        case .white: return .white
        case .gray:  return Color(.systemGray5)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .white: return .labelBlack.opacity(0.08)
        case .gray:  return .clear
        }
    }
}
