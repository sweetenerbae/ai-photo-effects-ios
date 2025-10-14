//
//  RateUsView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//

import SwiftUI

struct RateUsView: View {
    let onBack: () -> Void
    let appID: String

    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                CircleButton(system: "chevron.left", action: onBack)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                Spacer()
                Text("Rate us")
                    .font(.system(size: 17, weight: .semibold))
                Spacer().frame(width: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Image("rate_heart") 
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 240)
                        .padding(.top, 28)

                    Text("Do you like our app?")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.primaryOrange)

                    Text("Please rate our app so we can improve it for you and make it even cooler.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.labelBlack)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(0.7)

                    HStack(spacing: 8) {
                        ActionButton(title: "No", style: .secondary) {
                            onBack()
                        }

                        ActionButton(title: "Yes", style: .primary) {
                            RateUsManager.requestReviewOrRedirect(appID: appID)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .safeAreaPadding(.bottom)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// Buttons
private struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryOrange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

private struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.grayButton)
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

#Preview("RateUsView") {
    RateUsView(onBack: {}, appID: "1234567890")
        .environment(\.colorScheme, .light)
}
