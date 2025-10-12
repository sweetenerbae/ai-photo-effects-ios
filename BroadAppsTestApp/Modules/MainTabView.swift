//
//  MainTabView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        let dim = UIColor(named: "LabelBlack")!.withAlphaComponent(0.5)
        let active = UIColor(named: "PrimaryOrange")!

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
        TabView {
            EffectsRootView()
                .tabItem {
                    Image("state=effects").renderingMode(.template)
                    Text("Effects")
                }

            AiPhotoView()
                .tabItem {
                    Image("state=images").renderingMode(.template)
                    Text("Ai photo")
                }

            HistoryView()
                .tabItem {
                    Image("state=history").renderingMode(.template)
                    Text("History")
                }

            SettingsView()
                .tabItem {
                    Image("state=settings").renderingMode(.template)
                    Text("Settings")
                }
        }
        .tint(Color("PrimaryOrange")) 
    }
}
