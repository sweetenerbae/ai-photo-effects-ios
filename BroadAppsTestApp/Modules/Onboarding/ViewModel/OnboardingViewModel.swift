//
//  OnboardingViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//
import Foundation
import SwiftUI
import Combine

protocol OnboardingRouting: AnyObject {
    func closeOnboarding()
}

final class OnboardingViewModel: ObservableObject {
    // Output
    @Published private(set) var index: Int = 0
    let slides: [OnboardingSlide]

    // Deps
    private var storage: OnboardingStorage
    private weak var router: OnboardingRouting?

    init(
        slides: [OnboardingSlide],
        storage: OnboardingStorage,
        router: OnboardingRouting? = nil
    ) {
        self.slides = slides
        self.storage = storage
        self.router = router
    }

    // Inputs
    func setIndex(_ newIndex: Int) {
        guard (0..<slides.count).contains(newIndex) else { return }
        index = newIndex
    }

    func onBack() {
        setIndex(max(index - 1, 0))
    }

    func onContinue() {
        if index < slides.count - 1 {
            setIndex(index + 1)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            complete()
        }
    }

    func onSkip() { complete() }

    private func complete() {
        storage.hasCompleted = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        router?.closeOnboarding()
    }
}
