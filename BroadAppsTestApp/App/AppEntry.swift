//
//  AppEntry.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//
import SwiftUI

private enum AppState { case launching, onboarding, home }

struct AppEntry: View {
    @StateObject private var storage = AppStorageOnboarding()
    @StateObject private var tabRouter = TabRouter()
    @State private var state: AppState = .launching

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
            switch state {
            case .launching:
                SplashView()          
                    .task { await bootstrap() }

            case .onboarding:
                OnboardingView(
                    vm: OnboardingViewModel(slides: slides, storage: storage)
                )
                    .onChange(of: storage.hasCompleted) { _, newValue in if newValue { state = .home } }

            case .home:
                MainTabView()
                    .environmentObject(tabRouter)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: state)
    }

    private func bootstrap() async {
        await MainActor.run {
            state = storage.hasCompleted ? .home : .onboarding //todo
        }
    }
}
