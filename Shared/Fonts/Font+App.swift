//
//  Font+App.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 14.10.25.
//

import SwiftUI

enum AppTextStyle {
    case body        // Medium 16
    case small       // Medium 15
    case button      // Semibold 18
    case title       // Semibold 26

    var font: Font {
        switch self {
        case .body:
            return .custom("InterTight-Medium", size: 16, relativeTo: .body)
        case .small:
            return .custom("InterTight-Medium", size: 15, relativeTo: .callout)
        case .button:
            return .custom("InterTight-Semibold", size: 18, relativeTo: .headline)
        case .title:
            return .custom("InterTight-Semibold", size: 26, relativeTo: .title2)
        }
    }
}

extension View {
    func appFont(_ style: AppTextStyle) -> some View {
        self.font(style.font)
    }
}
