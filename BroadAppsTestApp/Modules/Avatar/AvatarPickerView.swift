//
//  AvatarPickerView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 20.10.25.
//

import SwiftUI
import Combine

struct AvatarPickerView: View {
    @Binding var selectedAvatar: FotobudkaAvatar?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: AvatarPickerViewModel
    @State private var showingAvatarCreation = false

    init(selectedAvatar: Binding<FotobudkaAvatar?>, env: AppEnvironment = .live) {
        self._selectedAvatar = selectedAvatar
        self._vm = StateObject(wrappedValue: AvatarPickerViewModel(env: env))
    }

    var body: some View {
        NavigationView {
            VStack {
                if vm.isLoading {
                    ProgressView("Loading avatars...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.errorMessage {
                    emptyStateView(message: error)
                } else if vm.avatars.isEmpty {
                    emptyStateView(message: "You don't have any avatars yet. Create your first avatar!")
                } else {
                    avatarsGridView
                }
            }
            .navigationTitle("Choose Avatar")
            .fullScreenCover(isPresented: $showingAvatarCreation) {
                AvatarCreationFlowView()
            }
            .onChange(of: showingAvatarCreation) { _, isPresented in
                if !isPresented {
                    vm.loadAvatars()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                vm.loadAvatars()
            }
        }
    }

    private var avatarsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                ForEach(vm.avatars) { avatar in
                    Button(action: {
                        selectedAvatar = avatar
                        dismiss()
                    }) {
                        VStack {
                            AsyncThumb(urlString: avatar.preview)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())

                            Text(avatar.title ?? "Avatar \(avatar.id)")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Create Avatar") {
                showingAvatarCreation = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
