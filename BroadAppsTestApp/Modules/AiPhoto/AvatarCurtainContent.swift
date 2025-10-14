//
//  AvatarCurtainContent.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI
import PhotosUI

struct AvatarCurtainContent: View {
    @ObservedObject var vm: AiPhotoViewModel
    @Binding var addAvatarPickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                PhotosPicker(selection: $addAvatarPickerItem, matching: .images) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.grayButton).frame(width: 72, height: 72)
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        Text("Create an avatar")
                            .font(.system(size: 13))
                            .foregroundStyle(.primary)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(vm.avatars) { avatar in
                            Button {
                                vm.selectedAvatar = avatar
                                vm.activeSheet = nil
                            } label: {
                                VStack(spacing: 8) {
                                    Image(uiImage: avatar.image)
                                        .resizable().scaledToFill()
                                        .frame(width: 72, height: 72)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(vm.selectedAvatar == avatar ? Color.primary : .clear, lineWidth: 2))
                                    Text(avatar.name).font(.system(size: 13))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if vm.selectedAvatar != nil {
                Button(role: .destructive) {
                    vm.deleteSelectedAvatar()
                } label: {
                    Text("Delete selected avatar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding(.top, 8)
    }
}
