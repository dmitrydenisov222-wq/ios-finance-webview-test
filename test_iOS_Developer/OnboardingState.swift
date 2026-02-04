import SwiftUI
import Combine

// MARK: - UserDefaults keys

enum OnboardingDefaultsKeys {
    static let completed = "onboardingCompleted"
}

// MARK: - Onboarding state

/// Состояние онбординга: отвечает за то, показывать ли экран приветствия.
final class OnboardingState: ObservableObject {
    /// Флаг завершённого онбординга, читается и пишется в UserDefaults.
    @Published var isCompleted: Bool

    init() {
        // Читаем значение из UserDefaults, по умолчанию false.
        self.isCompleted = UserDefaults.standard.bool(forKey: OnboardingDefaultsKeys.completed)
    }

    /// Отмечает онбординг как завершённый и сохраняет это в UserDefaults.
    func markCompleted() {
        isCompleted = true
        UserDefaults.standard.set(true, forKey: OnboardingDefaultsKeys.completed)
    }
}
