//
//  AppEntry.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//
import SwiftUI

struct AppEntry: View {
    @StateObject private var storage = AppStorageOnboarding()

    private let slides: [OnboardingSlide] = [
        .init(title: "Welcome to App",
              subtitle: "Generate unique images and videos in seconds using a neural network",
              background: AnyView(OrangeSolidBG())),
        .init(title: "Transform your photo using effects",
              subtitle: "Turn ordinary moments into unique digital art in one tap",
              background: AnyView(OrangeSolidBG())),
        .init(title: "Go viral with new trends",
              subtitle: "Get noticed with trending effects every day.",
              background: AnyView(OrangeSolidBG()))
    ]

    var body: some View {
        Group {
            if storage.hasCompleted {
                RootContentView()
            } else {
                OnboardingView(
                    vm: OnboardingViewModel(slides: slides, storage: storage)
                )
            }
        }
    }
}

struct RootContentView: View {
    var body: some View {
        Text("Main app here")
            .font(.title)
            .padding()
    }
}
