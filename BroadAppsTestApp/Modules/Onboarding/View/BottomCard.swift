//
//  BottomCard.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//
import SwiftUI

struct BottomCard: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.labelBlack)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.labelBlack)
                .opacity(0.7)
                .multilineTextAlignment(.center)

            Button(buttonTitle, action: action)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryOrange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain) 
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .safeAreaPadding(.bottom)
        .frame(maxWidth: .infinity)
        .background(
            RoundedCorner(radius: 32, corners: [.topLeft, .topRight])
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 25.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
