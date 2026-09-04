//
//  TabRouter.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import Combine

final class TabRouter: ObservableObject {
    enum Tab { case effects, ai, history, settings }
    @Published var selected: Tab = .effects
}
