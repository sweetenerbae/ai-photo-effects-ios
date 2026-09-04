//
//  AppEntry.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//
import SwiftUI

private enum AppState: Equatable {
    case launching
    case onboarding
    case home
    case failed(String)
}

struct AppEntry: View {
    @StateObject private var storage = AppStorageOnboarding()
    @StateObject private var tabRouter = TabRouter()
    @State private var state: AppState = .launching
    private let environment = AppEnvironment.live

    private let slides: [OnboardingSlide] = [
        .init(title: "Welcome to \(AppConfig.appDisplayName)",
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
                .onChange(of: storage.hasCompleted) { _, newValue in
                    if newValue { state = .home }
                }

            case .home:
                MainTabView()
                    .environmentObject(tabRouter)

            case .failed(let message):
                ContentUnavailableView {
                    Label("Unable to Start", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") {
                        state = .launching
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: state)
    }

    @MainActor
    private func bootstrap() async {
        if AppConfig.isPortfolioMode {
            state = storage.hasCompleted ? .home : .onboarding
            return
        }

        do {
            let authService = AuthService(networkClient: environment.networkClient)
            _ = try await authService.fullAuthProcess()
            state = storage.hasCompleted ? .home : .onboarding
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
