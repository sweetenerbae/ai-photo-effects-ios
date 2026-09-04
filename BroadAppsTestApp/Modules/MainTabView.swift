//
//  MainTabView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI
import Combine
import UIKit

struct MainTabView: View {
    @EnvironmentObject var tabRouter: TabRouter

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        let dim = (UIColor(named: "LabelBlack") ?? .darkGray).withAlphaComponent(0.5)
        let active = UIColor(named: "PrimaryOrange") ?? .systemOrange

        appearance.stackedLayoutAppearance.normal.iconColor = dim
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: dim,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = active
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: active,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]

        appearance.stackedItemPositioning = .automatic
        appearance.stackedItemWidth = 70
        appearance.stackedItemSpacing = 0
        UITabBar.appearance().itemPositioning = .automatic
        UITabBar.appearance().itemWidth = 70
        UITabBar.appearance().itemSpacing = 0

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $tabRouter.selected) {
            EffectsRootView()
                .tabItem {
                    Image("state=effects").renderingMode(.template)
                    Text("Effects")
                }
                .tag(TabRouter.Tab.effects)

            AiPhotoView()
                .tabItem {
                    Image("state=images").renderingMode(.template)
                    Text("Ai photo")
                }
                .tag(TabRouter.Tab.ai)

            HistoryView()
                .tabItem {
                    Image("state=history").renderingMode(.template)
                    Text("History")
                }
                .tag(TabRouter.Tab.history)

            SettingsView()
                .tabItem {
                    Image("state=settings").renderingMode(.template)
                    Text("Settings")
                }
                .tag(TabRouter.Tab.settings)
        }
        .onChange(of: tabRouter.selected) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
        .environmentObject(tabRouter)
        .tint(Color("PrimaryOrange"))
    }
}
