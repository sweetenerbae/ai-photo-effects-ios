//
//  OnboardingStorage.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//

import SwiftUI
import Combine

protocol OnboardingStorage {
    var hasCompleted: Bool { get set }
}

final class AppStorageOnboarding: ObservableObject, OnboardingStorage {
    @AppStorage("hasCompletedOnboarding") private var flag = false {
        didSet { objectWillChange.send() }
    }

    var hasCompleted: Bool {
        get { flag }
        set { flag = newValue }
    }
}
