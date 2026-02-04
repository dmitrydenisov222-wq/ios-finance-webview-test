import SwiftUI

/// Корневой экран модуля 1:
/// показывает либо онбординг, либо основной экран с финансами.
struct Module1RootView: View {
    @StateObject private var onboardingState = OnboardingState()

    var body: some View {
        if onboardingState.isCompleted {
            FinanceMainView()
        } else {
            OnboardingView(onboardingState: onboardingState)
        }
    }
}
