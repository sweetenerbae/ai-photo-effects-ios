//
//  BottomCurtain.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//
import SwiftUI

struct BottomCurtain<Content: View>: View {
    let detents: Set<PresentationDetent> = [.medium, .large]
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 12) {
            Capsule().fill(Color(.systemGray3)).frame(width: 40, height: 5).padding(.top, 8)
            content()
            Spacer(minLength: 8)
        }
        .presentationDetents(detents)
    }
}
