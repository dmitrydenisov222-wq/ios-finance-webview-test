import SwiftUI

/// Онбординг для модуля с финансами.
struct OnboardingView: View {
    @ObservedObject var onboardingState: OnboardingState
    @State private var currentPage = 0

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "Добро пожаловать",
                    subtitle: "Приложение поможет учитывать доходы и расходы."
                )
                .tag(0)

                OnboardingPageView(
                    title: "График и история",
                    subtitle: "Смотрите динамику и список операций в одном месте."
                )
                .tag(1)

                OnboardingLastPageView {
                    onboardingState.markCompleted()
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

// MARK: - Regular onboarding page

struct OnboardingPageView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text(title)
                .font(.title)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Last onboarding page with button

struct OnboardingLastPageView: View {
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("Готово к старту")
                .font(.title)
                .multilineTextAlignment(.center)

            Text("Нажмите кнопку ниже, чтобы перейти к учёту финансов.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Spacer()

            Button(action: onFinish) {
                Text("Начать")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
