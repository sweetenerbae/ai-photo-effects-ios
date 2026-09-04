//
//  ImageActionsView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 19.10.25.
//

import SwiftUI

struct ImageActionsView: View {
    let onDownload: () -> Void
    let onShare: () -> Void
    let onRemove: () -> Void
    let isSaving: Bool
    var showRemove: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            ActionButton(
                title: isSaving ? "Saving..." : "Download",
                style: .primary,
                iconName: "download"
            ) {
                onDownload()
            }
            .disabled(isSaving)

            shareButton

            if showRemove {
                removeButton
            }
        }
        .padding(16)
        .background(Color.white)
    }

    // MARK: - Custom Buttons

    private var shareButton: some View {
        Button(action: onShare) {
            HStack(spacing: 8) {
                Image("share")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("Share")
                    .appFont(.body)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.clear)
            .foregroundColor(Color.labelBlack)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.primaryOrange, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
    }

    private var removeButton: some View {
        Button(action: onRemove) {
            HStack(spacing: 8) {
                Image("trash")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("Remove")
                    .appFont(.body)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.clear)
            .foregroundColor(Color.labelBlack.opacity(0.6))
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
    }
}
