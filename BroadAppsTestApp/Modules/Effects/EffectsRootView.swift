import SwiftUI
import Combine
import SDWebImageSwiftUI

// Маршрут для создания
struct EffectCreationRoute: Hashable {
    let templateId: Int
    let categoryTitle: String
}

struct EffectsRootView: View {
    @StateObject private var vm = EffectsViewModel(env: .live)
    private let cardW = min(UIScreen.main.bounds.width * 0.36, 170)

    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .idle, .loading:
                    ScrollView {
                        VStack(spacing: 24) {
                            shimmerSection(title: "Loading…")
                        }
                        .padding(.top, 12)
                    }

                case .failed(let message):
                    VStack(spacing: 12) {
                        Text(message).foregroundStyle(.secondary)
                        Button("Retry") { vm.retry() }
                    }
                    .padding(24)

                case .loaded(let categories):
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(categories.filter { !$0.templates.isEmpty }) { cat in
                                categorySection(cat)
                            }
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { vm.load() }

            .navigationDestination(for: CategoryRoute.self) { route in
                if case .loaded(let categories) = vm.state,
                   let cat = categories.first(where: { $0.id == route.id }) {
                    CategoryGridView(title: route.title, templates: cat.templates)
                } else {
                    CategoryGridView(title: route.title, templates: [])
                }
            }

            .navigationDestination(for: EffectCreationRoute.self) { route in
                // Находим шаблон по ID из всех категорий
                if case .loaded(let categories) = vm.state {
                    if let template = findTemplateById(route.templateId, in: categories) {
                        EffectCreationView(
                            template: template,
                            categoryTitle: route.categoryTitle
                        )
                    } else {
                        // Fallback view если шаблон не найден
                        EmptyEffectCreationView(categoryTitle: route.categoryTitle)
                    }
                } else {
                    EmptyEffectCreationView(categoryTitle: route.categoryTitle)
                }
            }
        }
    }

    @ViewBuilder
    private func categorySection(_ cat: PhotoStyleCategory) -> some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(cat.title ?? "Category \(cat.id)")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                NavigationLink(value: CategoryRoute(id: cat.id, title: cat.title ?? "Category")) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(cat.templates) { tmpl in
                        NavigationLink(
                            value: EffectCreationRoute(
                                templateId: tmpl.id,
                                categoryTitle: cat.title ?? "Category"
                            )
                        ) {
                            EffectThumbCard(
                                preview: tmpl.preview,
                                width: cardW
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func shimmerSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: cardW, height: cardW / 0.7)
                            .redacted(reason: .placeholder)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // поиск шаблона по ID
    private func findTemplateById(_ id: Int, in categories: [PhotoStyleCategory]) -> PhotoStyle? {
        for category in categories {
            if let template = category.templates.first(where: { $0.id == id }) {
                return template
            }
        }
        return nil
    }
}

// Fallback view для случая когда шаблон не найден
struct EmptyEffectCreationView: View {
    let categoryTitle: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                title: categoryTitle,
                leading: {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.labelBlack)
                    }
                },
                trailing: {
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.labelBlack)
                    }
                }
            )

            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                Text("Template not found")
                    .font(.headline)
                Text("The selected template is no longer available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct EffectThumbCard: View {
    let preview: String?
    let width: CGFloat

    private var height: CGFloat { width / 0.7 }
    private let corner: CGFloat = 16

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncThumb(urlString: preview)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))

            LinearGradient(colors: [.clear, .black.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .frame(width: width, height: height)
        }
        .frame(width: width, height: height)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}
