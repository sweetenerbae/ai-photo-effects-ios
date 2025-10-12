//
//  AiPhotoView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI
import PhotosUI

struct AiPhotoView: View {
    @StateObject private var vm = AiPhotoViewModel(
        service: StubImageGenService(),
        history: HistoryStore.shared
    )

    @FocusState private var promptFocused: Bool
    @State private var addAvatarPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 16) {

                    Group {
                        switch vm.state {
                        case .idle:
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 48, weight: .regular))
                                    .foregroundStyle(.secondary)
                                Text("Image")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 260)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        case .loading:
                            VStack(spacing: 12) {
                                ProgressView().progressViewStyle(.circular)
                                Text("The image is generated, wait for the end of the process.\nYou can later find it in History.")
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 260)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        case .result(let image):
                            VStack(spacing: 12) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay {
                                        if vm.useAvatar, let avatar = vm.avatarThumb {
                                            Image(uiImage: avatar)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 44, height: 44)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(.white, lineWidth: 2))
                                                .shadow(radius: 4)
                                                .padding(10)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        }
                                    }

                                HStack(spacing: 12) {
                                    ActionButton(title: "Download", style: .secondary) { vm.saveToPhotos() }
                                    ActionButton(title: "Share", style: .secondary)     { vm.share() }
                                    ActionButton(title: "Remove", style: .secondary)    { vm.clearResult() }
                                }
                            }
                        }
                    }
                    .overlay {
                        PhotosPicker(selection: $vm.basePickerItem, matching: .images) {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                        }
                    }
                    .onChange(of: vm.basePickerItem) { newItem in
                        vm.didPickBasePhoto(newItem)
                    }

                    // Aspect ratio capsule (full-width)
                    Button {
                        vm.showAspectSheet = true
                    } label: {
                        FullWidthCapsule(title: vm.aspect.title)
                    }
                    .buttonStyle(.plain)

                    // Avatar capsule (full-width)
                    Button {
                        vm.showAvatarSheet = true
                    } label: {
                        FullWidthCapsule(title: vm.selectedAvatar?.name ?? "Avatar")
                    }
                    .buttonStyle(.plain)

                    // Prompt
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $vm.prompt)
                            .focused($promptFocused)
                            .frame(minHeight: 96)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        if vm.prompt.isEmpty {
                            Text("Describe your dream photo — e.g., ‘A cat astronaut on Mars wearing a gold spacesuit’")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .allowsHitTesting(false)
                        }
                    }

                    // Generate
                    ActionButton(
                        title: "Generate",
                        style: .primary
                    ) { vm.generate() }
                    .opacity(vm.isPromptValid ? 1.0 : 0.5)
                    .disabled(!vm.isPromptValid || vm.isLoading)
                }
                .padding(16)
            }
            .navigationTitle("Image generation")
            .hideKeyboardOnTap()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CircleButton(system: "chevron.left", action: { vm.onBack?() }, style: .white)
                        .opacity(vm.showBack ? 1 : 0)
                        .disabled(!vm.showBack)
                }
            }
            .sheet(item: $vm.activeSheet) { sheet in
                switch sheet {
                case .aspect:
                    BottomCurtain { AspectSheet(vm: vm) }
                case .avatar:
                    BottomCurtain { AvatarSheet(vm: vm, addAvatarPickerItem: $addAvatarPickerItem) }
                }
            }
        }
    }
}

private struct FullWidthCapsule: View {
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
