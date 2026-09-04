import Combine
import SwiftUI

struct EffectCreationView: View {
    let categoryTitle: String

    @StateObject private var viewModel: EffectCreationViewModel
    @State private var showingAvatarPicker = false
    @Environment(\.dismiss) private var dismiss

    init(
        template: PhotoStyle,
        categoryTitle: String,
        environment: AppEnvironment = .live
    ) {
        self.categoryTitle = categoryTitle
        _viewModel = StateObject(
            wrappedValue: EffectCreationViewModel(
                template: template,
                imageService: environment.imageGenService,
                avatarService: environment.avatarService,
                history: .shared
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: categoryTitle) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.labelBlack)
                }
            } trailing: {
                Color.clear
            }

            ZStack {
                if let image = viewModel.generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    AsyncThumb(urlString: viewModel.template.displayPreview)
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .background(Color.gray.opacity(0.1))

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }

            VStack(spacing: 12) {
                ActionButton(
                    title: viewModel.selectedAvatar == nil ? "Use Avatar" : "Change Avatar",
                    style: .secondary,
                    iconName: "person-add"
                ) {
                    showingAvatarPicker = true
                }

                ActionButton(title: "Generate", style: .primary, iconName: "spark") {
                    viewModel.generate()
                }
                .disabled(viewModel.selectedAvatar == nil || viewModel.isLoading)
            }
            .padding(16)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPickerView(selectedAvatar: $viewModel.selectedAvatar)
        }
    }
}

@MainActor
final class EffectCreationViewModel: ObservableObject {
    let template: PhotoStyle

    @Published var selectedAvatar: FotobudkaAvatar?
    @Published private(set) var generatedImage: UIImage?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let imageService: ImageGenService
    private let avatarService: AvatarServicing
    private let history: HistoryStore
    private var generationTask: Task<Void, Never>?

    init(
        template: PhotoStyle,
        imageService: ImageGenService,
        avatarService: AvatarServicing,
        history: HistoryStore
    ) {
        self.template = template
        self.imageService = imageService
        self.avatarService = avatarService
        self.history = history
    }

    func generate() {
        guard let selectedAvatar, !isLoading else { return }
        generationTask?.cancel()
        isLoading = true
        errorMessage = nil

        generationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let avatarImage = await avatarService.loadAvatarImage(from: selectedAvatar.preview)
                let prompt = template.prompt ?? template.displayTitle
                let image = try await imageService.generate(
                    prompt: prompt,
                    avatar: avatarImage,
                    aspect: .a4x5,
                    template: template
                )
                try Task.checkCancellation()
                generatedImage = image
                history.appendFinished(
                    image: image,
                    prompt: prompt,
                    usedAvatar: true,
                    templateName: template.displayTitle
                )
                isLoading = false
            } catch is CancellationError {
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
