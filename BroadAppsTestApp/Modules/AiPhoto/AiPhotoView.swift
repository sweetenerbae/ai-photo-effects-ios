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
    @StateObject private var vm: AiPhotoViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @FocusState private var promptFocused: Bool
    @State private var addAvatarPickerItem: PhotosPickerItem?
    @State private var showCreateAvatar = false
    @State private var showAvatarAlert = false
    @State private var showPaywall = false
    @EnvironmentObject var tabRouter: TabRouter

    init(environment: AppEnvironment = .live) {
        _vm = StateObject(
            wrappedValue: AiPhotoViewModel(
                service: environment.imageGenService,
                history: HistoryStore.shared
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                // ПОЛНОЭКРАННЫЙ ЭКРАН ГЕНЕРАЦИИ
                if case .generating = vm.state {
                    fullScreenGeneratingView
                } else {
                    // ОБЫЧНЫЙ ИНТЕРФЕЙС
                    normalInterfaceView
                }
            }
            .hideKeyboardOnTap()
            .sheet(item: $vm.activeSheet) { sheet in
                switch sheet {
                case .aspect:
                    BottomCurtain(title: "") { AspectCurtainContent(vm: vm) }
                case .avatar:
                    BottomCurtain(title: "Avatar") { AvatarCurtainContent(vm: vm, addAvatarPickerItem: $addAvatarPickerItem) }
                }
            }
            .sheet(isPresented: $showCreateAvatar) {
                AvatarCreationFlowView()
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .alert("The avatar has not been created", isPresented: $showAvatarAlert) {
                Button("Not now", role: .cancel) { }
                Button("To create") {
                    if !SubscriptionManager.shared.isSubscribed {
                        showPaywall = true
                    } else {
                        showCreateAvatar = true
                    }
                }
            } message: {
                Text("Would you like to create it now?")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private var fullScreenGeneratingView: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.4)

                Text("Generating image... It will appear in your gallery shortly.")
                    .appFont(.small)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: 320)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }


    // MARK: - Обычный интерфейс
    private var normalInterfaceView: some View {
        VStack(spacing: 8) {
            TopBar(title: "Image generation") {
                CircleButton(system: "chevron.left", action: { tabRouter.selected = .effects }, style: .gray)
            } trailing: {
                Color.clear
            }
            .padding(.top, 12)
            .background(Color.white.ignoresSafeArea(edges: .top))

            // Контент изображения
            Group {
                switch vm.state {
                case .idle:
                    HStack(spacing: 8) {
                        Image("state=images").renderingMode(.template)
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
                    }

                case .failed(let message):
                    ContentUnavailableView(
                        "Generation Failed",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                    .frame(maxWidth: .infinity, minHeight: 260)

                case .generating:
                    EmptyView()
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

            // Нижняя панель с контролами
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Button { vm.activeSheet = .aspect } label: {
                        CapsuleTile(title: vm.aspect.title, iconName: vm.aspect.iconName)
                    }
                    .buttonStyle(.plain)

                    Button {
                        if vm.avatars.isEmpty {
                            showAvatarAlert = true
                        } else {
                            vm.activeSheet = .avatar
                        }
                    } label: {
                        CapsuleTile(title: vm.selectedAvatar?.name ?? "Avatar", iconName: "person-add")
                    }
                    .buttonStyle(.plain)
                }

                // Промпт
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $vm.prompt)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.primary)
                        .focused($promptFocused)
                        .frame(minHeight: 60)
                        .padding(8)
                        .background(Color(.grayButton))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    if vm.prompt.isEmpty {
                        Text("Describe your dream photo — e.g., ‘A cat astronaut on Mars wearing a gold spacesuit’")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .allowsHitTesting(false)
                    }
                }

                // Кнопка генерации
                ActionButton(
                    title: "Generate",
                    style: .primary,
                    iconName: "spark"
                ) {
                    if !SubscriptionManager.shared.isSubscribed {
                        showPaywall = true
                        return
                    }
                    vm.generate()
                }
                .opacity(vm.isPromptValid ? 1.0 : 0.5)
                .disabled(!vm.isPromptValid || vm.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, keyboard.height + 6)
            .animation(.easeOut(duration: 0.25), value: keyboard.height)
        }
    }
}

private struct CapsuleTile: View {

    let title: String
    var iconName: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let iconName = iconName {
                Image(iconName)
                    .font(.system(size: 16))
            }
            Text(title)
                .appFont(.small)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.grayButton))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
            DispatchQueue.main.async { self?.height = 0 }
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
        DispatchQueue.main.async { [weak self] in
            self?.height = overlap - window.safeAreaInsets.bottom
        }
    }
}

#Preview {
    AiPhotoView()
}
