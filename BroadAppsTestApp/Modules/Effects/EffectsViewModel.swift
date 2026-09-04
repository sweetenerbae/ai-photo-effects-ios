//
//  EffectsViewModel.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.
//

import Foundation
import Combine

@MainActor
final class EffectsViewModel: ObservableObject {
    enum State { case idle, loading, loaded([PhotoStyleCategory]), failed(String) }

    @Published private(set) var state: State = .idle
    @Published var gender: String = "f"

    private let env: AppEnvironment
    private var loadTask: Task<Void, Never>?

    init(env: AppEnvironment) { self.env = env }

    func load() {
        guard case .idle = state else { return }
        state = .loading
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let cats = try await env.effectsRepo.fetchCategories(
                    lang: "en", gender: gender, tag: nil, showAll: false
                )
                try Task.checkCancellation()
                state = .loaded(cats)
            } catch is CancellationError {
                state = .idle
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func retry() {
        loadTask?.cancel()
        state = .idle
        load()
    }
}
