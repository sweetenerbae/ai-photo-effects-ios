//
//  BottomCurtain.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//
import SwiftUI

struct BottomCurtain<Content: View>: View {
    let title: String?
    var detents: Set<PresentationDetent> = [.medium, .large]
    var showsGrabber: Bool = true
    var dismissOnBackgroundTap: Bool = true
    @ViewBuilder var content: () -> Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            if showsGrabber {
                Capsule().fill(Color(.systemGray3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
            }

            if let title {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.top, showsGrabber ? 0 : 8)
            }

            content()
                .padding(.horizontal, 16)

            Spacer(minLength: 8)
        }
        .presentationDetents(detents)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(!dismissOnBackgroundTap)
    }
}

