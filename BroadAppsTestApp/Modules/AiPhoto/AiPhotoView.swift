//
//  AiPhotoView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 11.10.25.
//

import SwiftUI
import PhotosUI
import Combine
import UIKit

struct AiPhotoView: View {
    @StateObject private var vm = AiPhotoViewModel(
        service: StubImageGenService(),
        history: HistoryStore.shared
    )

    @FocusState private var promptFocused: Bool
    @State private var addAvatarPickerItem: PhotosPickerItem?
    @State private var showCreateAvatar = false
    @State private var showAvatarAlert = false
    @EnvironmentObject var tabRouter: TabRouter
    @StateObject private var keyboard = KeyboardObserver()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 8) {
                    TopBar(title: "Image generation") {
                        CircleButton(system: "chevron.left", action: { tabRouter.selected = .effects }, style: .gray)
                    } trailing: {
                        Color.clear
                    }
                    .padding(.top, 12)
                    .background(Color.white.ignoresSafeArea(edges: .top))
                    
                    Group {
                        switch vm.state {
                        case .idle:
                            HStack(spacing: 8) {
                                Image("state=images")
                                    .font(.system(size: 32, weight: .regular))
                                    .foregroundStyle(.gray2)
                                Text("Image")
                                    .appFont(.title)
                                    .foregroundStyle(.gray2)
                            }
                            .frame(maxWidth: .infinity, minHeight: 260)

                        case .loading:
                            VStack(spacing: 12) {
                                ProgressView().progressViewStyle(.circular)
                                Text("The image is generated, wait for the end of the process.\nYou can later find it in History.")
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 260)
                            .background(Color(.grayButton))
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
                    .onChange(of: vm.basePickerItem) { _, newItem in
                        vm.didPickBasePhoto(newItem)
                    }

                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Button { vm.activeSheet = .aspect } label: {
                                CapsuleTile(title: vm.aspect.title)
                            }
                            .buttonStyle(.plain)

                            Button {
                                if vm.avatars.isEmpty {
                                    showAvatarAlert = true
                                } else {
                                    vm.activeSheet = .avatar
                                }
                            } label: {
                                CapsuleTile(title: vm.selectedAvatar?.name ?? "Avatar")
                            }
                            .buttonStyle(.plain)
                        }
                        // Prompt
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $vm.prompt)
                                .scrollContentBackground(.hidden)
                                .foregroundStyle(.primary)
                                .focused($promptFocused)
                                .frame(minHeight: 96)
                                .padding(8)
                                .background(Color(.grayButton))
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
                    .padding(.bottom, max(0, keyboard.height * 0.6))
                    .animation(.easeOut(duration: 0.25), value: keyboard.height)
                }
                .padding(16)
            }
            .hideKeyboardOnTap()
            .sheet(item: $vm.activeSheet) { sheet in
                switch sheet {
                case .aspect:
                    BottomCurtain(title: "Aspect ratio") { AspectCurtainContent(vm: vm) }
                case .avatar:
                    BottomCurtain(title: "Avatar") { AvatarCurtainContent(vm: vm, addAvatarPickerItem: $addAvatarPickerItem) }
                }
            }
            // Открытие мастера создания аватара
            .sheet(isPresented: $showCreateAvatar) {
                AvatarCreationFlowView()
            }

            //Алерт, если аватар не создан
            .alert("The avatar has not been created", isPresented: $showAvatarAlert) {
                Button("Not now", role: .cancel) { }
                Button("To create") {
                    showCreateAvatar = true
                }
            } message: {
                Text("Would you like to create it now?")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct CapsuleTile: View {
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            Image("")
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.grayButton))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - Keyboard Observer
final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    private var willChange: NSObjectProtocol?
    private var willHide: NSObjectProtocol?

    init() {
        let nc = NotificationCenter.default
        willChange = nc.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] note in
            self?.handle(note: note)
        }
        willHide = nc.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.height = 0
        }
    }

    deinit {
        let nc = NotificationCenter.default
        if let willChange { nc.removeObserver(willChange) }
        if let willHide { nc.removeObserver(willHide) }
    }

    private func handle(note: Notification) {
        guard
            let userInfo = note.userInfo,
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.keyWindow
        else { return }

        let kbFrameInView = window.convert(endFrame, to: nil)
        let overlap = max(0, window.bounds.maxY - kbFrameInView.minY)
        height = overlap - window.safeAreaInsets.bottom
    }
}
