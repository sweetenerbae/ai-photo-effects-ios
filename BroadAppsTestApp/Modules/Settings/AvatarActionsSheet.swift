//
//  AvatarActionsSheet.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI

struct AvatarActionsSheet: View {
    let name: String
    let onRename: () -> Void
    let onChangePhoto: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Capsule().fill(Color(.systemGray3)).frame(width: 40, height: 5).padding(.top, 8)

            Text("Manage avatar")
                .font(.system(size: 17, weight: .semibold))
                .padding(.top, 8)

            Button("Rename the avatar (\(name))", action: onRename)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button("Change the avatar photo", action: onChangePhoto)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(role: .destructive, action: onDelete) {
                Text("Delete an avatar")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 16)
    }
}
