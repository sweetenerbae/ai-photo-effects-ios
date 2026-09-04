import SwiftUI
import Combine

struct OnboardingView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var isDragging = false

    var body: some View {
        ZStack {
            vm.slides[clamp(vm.index, 0, vm.slides.count - 1)].background
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: vm.index)

           TabView(selection: Binding(
               get: { vm.index },
               set: { vm.setIndex($0) }
           )) {
               ForEach(vm.slides.indices, id: \.self) { i in
                   SlideView(slide: vm.slides[i])
                       .tag(i)
                       //.padding(.horizontal, 16)
                       .ignoresSafeArea(.container, edges: .top)
               }
           }
           .tabViewStyle(.page(indexDisplayMode: .never))
           .animation(isDragging ? nil : .interactiveSpring(response: 0.5, dampingFraction: 0.85), value: vm.index)
           .gesture(DragGesture().onChanged { _ in isDragging = true }.onEnded { _ in isDragging = false })
           .ignoresSafeArea()

            // Градиент
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primaryOrange.opacity(1.0),
                        Color.primaryOrange.opacity(0.9),
                        Color.primaryOrange.opacity(0.0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 450)
                .ignoresSafeArea(edges: .bottom)
            }
            .allowsHitTesting(false)

            VStack {
                HStack {
                    if vm.index > 0 {
                        CircleButton(system: "chevron.left", action: vm.onBack)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    } else {
                        Spacer().frame(width: 44, height: 44)
                    }
                    Spacer()
                    Button("Skip", action: vm.onSkip)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(0.95)
                        .accessibilityLabel("Skip onboarding")
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                BottomCard(
                    title: vm.slides[vm.index].title,
                    subtitle: vm.slides[vm.index].subtitle,
                    buttonTitle: vm.index == vm.slides.count - 1 ? "Start" : "Continue",
                    action: vm.onContinue
                )
            }
        }
    }
}

// helpers
private func clamp<T: Comparable>(_ value: T, _ minV: T, _ maxV: T) -> T {
    max(min(value, maxV), minV)
}

#Preview {
    let slides: [OnboardingSlide] = [
        .init(title: "Welcome to App",
              subtitle: "Generate unique images and videos in seconds using a neural network",
              background: AnyView(OrangeSolidBG())),
        .init(title: "Transform your photo using effects",
              subtitle: "Turn ordinary moments into unique digital art in one tap",
              background: AnyView(OrangeSolidBG())),
        .init(title: "Go viral with new trends",
              subtitle: "Get noticed with trending effects every day.",
              background: AnyView(OrangeSolidBG()))
    ]
    let vm = OnboardingViewModel(slides: slides, storage: AppStorageOnboarding())
    return OnboardingView(vm: vm)
}
