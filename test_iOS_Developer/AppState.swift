import SwiftUI
import Combine

// MARK: - Start destination

/// Модуль, который должен быть показан при запуске приложения.
enum AppStartDestination: String {
    case splash
    case module1
    case module2
}

// MARK: - UserDefaults keys

/// Ключи, используемые для хранения состояния приложения.
enum DefaultsKeys {
    /// Сохранённый выбор модуля старта: "module1" или "module2".
    static let moduleChoice = "moduleChoice"

    /// Последний загруженный в WebView URL.
    static let lastWebURL = "lastWebURL"
}

// MARK: - App state

/// Глобальное состояние приложения, определяющее стартовый экран.
final class AppState: ObservableObject {
    /// Текущее назначение старта. Меняем это поле, чтобы переключать корневой экран.
    @Published var startDestination: AppStartDestination = .splash
}
