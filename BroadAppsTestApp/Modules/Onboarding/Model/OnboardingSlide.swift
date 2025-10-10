//
//  OnboardingSlide.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//

import SwiftUI
import Foundation

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let background: AnyView
}
