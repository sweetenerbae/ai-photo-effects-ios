//
//  AvatarCreationFlowView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 13.10.25.
//
import SwiftUI
import PhotosUI

struct AvatarCreationFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = AvatarCreationViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Fixed Top Bar
                    TopBar(title: titleFor(vm.step)) {
                        CircleButton(system: "chevron.left", action: { dismiss() }, style: .gray)
                    } trailing: { Color.clear }
                    .padding(.top, 12)
                    .background(Color.white.ignoresSafeArea(edges: .top))

                    // Scrollable Step Content
                    GeometryReader { geo in
                        ScrollView(showsIndicators: false) {
                            VStack {
                                Group {
                                    switch vm.step {
                                    case .gender:   GenderStep(vm: vm)
                                    case .photos:   PhotosStep(vm: vm)
                                    case .progress: ProgressStep(vm: vm)
                                    case .name:     NameStep(vm: vm)
                                    case .preview:  PreviewStep(vm: vm)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, showBottomButton(vm.step) ? 24 : 118)
                            }
                            .frame(minHeight: geo.size.height)
                            .frame(width: geo.size.width, alignment: .top)
                        }
                    }

                    if showBottomButton(vm.step) {
                        ActionButton(title: "Continue", style: .primary) { vm.goNext() }
                            .opacity(isContinueEnabled(vm) ? 1 : 0.5)
                            .disabled(!isContinueEnabled(vm))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.ignoresSafeArea(edges: .bottom))
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func titleFor(_ step: AvatarCreationViewModel.Step) -> String {
        switch step {
        case .gender:  return "Creating an avatar"
        case .photos:  return "Added: \(vm.images.count)"
        case .progress:return "Creating an avatar"
        case .name:    return "Creating an avatar"
        case .preview: return "Avatar preview"
        }
    }
    private func isContinueEnabled(_ vm: AvatarCreationViewModel) -> Bool {
        switch vm.step {
        case .gender:  return vm.canContinueGender
        case .photos:  return vm.canContinuePhotos
        case .name:    return vm.canContinueName
        case .progress, .preview: return false
        }
    }
    private func showBottomButton(_ step: AvatarCreationViewModel.Step) -> Bool {
        step == .gender || step == .photos || step == .name
    }
}

// gender
private struct GenderStep: View {
    @ObservedObject var vm: AvatarCreationViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose the gender of\nyour avatar")
                .appFont(.title)
                .multilineTextAlignment(.center)

            Text("This will help you create\nyour own personal avatar.")
                .appFont(.body)
                .opacity(0.7)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 0)

            HStack(spacing: 8) {
                GenderCard(
                    title: "Woman",
                    selected: vm.gender == .woman,
                    imageName: "ob_face_up"
                ) { vm.gender = .woman }

                GenderCard(
                    title: "Man",
                    selected: vm.gender == .man,
                    imageName: "ob_face_center"
                ) { vm.gender = .man }
            }
        }
    }
}

private struct GenderCard: View {
    let title: String
    let selected: Bool
    let imageName: String
    let tap: () -> Void

    var body: some View {
        Button(action: { UISelectionFeedbackGenerator().selectionChanged()
            tap()
        }) {
            ZStack(alignment: .bottom) {
                // фон-фото
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 167, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                // затемнение снизу для читаемости подписи
                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.45)],
                    startPoint: .center, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .frame(width: 167, height: 300)

                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(selected ? Color.primaryOrange : .primaryOrange.opacity(0.7), lineWidth: 2)
                            .frame(width: 22, height: 22)
                        if selected {
                            Circle()
                                .fill(Color.primaryOrange)
                                .frame(width: 10, height: 10)
                        }
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10)
                .frame(width: 167 - 8)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.bottom, 4)
                .clipShape(Capsule())
                .padding(.horizontal, 4)
            }
            .frame(width: 167, height: 300)
        }
        .buttonStyle(.plain)
    }
}
// photo
private struct PhotosStep: View {
    @ObservedObject var vm: AvatarCreationViewModel
    @State private var selection: [PhotosPickerItem] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("Upload from 10 to 50 photos")
                .appFont(.body).opacity(0.8)
                .multilineTextAlignment(.center)

            if vm.images.isEmpty {
                PhotosPicker(selection: $selection, maxSelectionCount: 50, matching: .images) {
                    Text("Add a photo")
                        .appFont(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.clear)
                        .foregroundStyle(Color.primaryOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .contentShape(Rectangle())
                }
                .onChange(of: selection) { _, newSelection in
                    vm.pickedItems = newSelection
                    vm.convertPicked()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(vm.images, id: \.self) { img in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable().scaledToFill()
                                    .frame(height: 167)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                Button {
                                    vm.removeImage(img)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .appFont(.button)
                                        .foregroundStyle(.ultraThinMaterial)
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(.plain)
                                .padding(6)
                            }
                        }
                    }
                }

                PhotosPicker(selection: $selection, maxSelectionCount: 50, matching: .images) {
                    Text("Add more")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.grayButton)
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .contentShape(Rectangle())
                }
                .onChange(of: selection) { _, newSelection in
                    vm.pickedItems = newSelection
                    vm.convertPicked()
                }
            }

            if !vm.canContinuePhotos {
                Text("Select 10–50 photos. Avoid dark, blurry images; face should be clear.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

//progress
private struct ProgressStep: View {
    @ObservedObject var vm: AvatarCreationViewModel
    var body: some View {
        VStack(spacing: 12) {
            ProgressView().progressViewStyle(.circular)
            Text("Creating your avatar... This may take a few minutes.")
                .font(.footnote).multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("The image has been generated. Please wait for the process to complete or check it later in the settings...")
                .font(.footnote).multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(Color.grayButton)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

//name
private struct NameStep: View {
    @ObservedObject var vm: AvatarCreationViewModel
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Come up with a name\nfor your avatar")
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)

            TextField("Avatar name", text: $vm.avatarName)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Color.grayButton)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($focused)

            if let img = vm.generatedImage {
                HStack(spacing: -20) {
                    Image(uiImage: img).resizable().scaledToFill().frame(width: 140, height: 190).clipShape(RoundedRectangle(cornerRadius: 16))
                    Image(uiImage: img).resizable().scaledToFill().frame(width: 120, height: 170).clipShape(RoundedRectangle(cornerRadius: 16)).rotationEffect(.degrees(8)).offset(y: 8)
                }
            }
        }
        .onAppear { focused = true }
    }
}
//preview
private struct PreviewStep: View {
    @ObservedObject var vm: AvatarCreationViewModel
    var body: some View {
        VStack(spacing: 16) {
            if let img = vm.generatedImage {
                Image(uiImage: img)
                    .resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 4)
            }
            Text(vm.avatarName).font(.title3.bold())
                .padding(.top, 4)
        }
    }
}

#Preview("Avatar creation flow") {
    AvatarCreationFlowView()
        .environmentObject(AvatarLibrary.shared)
        .preferredColorScheme(.light)
}
