//
//  SplashView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 16) {
                Image("app_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
        }
    }
}

#Preview {
    SplashView()
}
