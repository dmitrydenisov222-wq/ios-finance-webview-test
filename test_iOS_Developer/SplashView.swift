import SwiftUI

/// Стартовый экран с лоадером, решающий, какой модуль показать.
struct SplashView: View {
    @EnvironmentObject var appState: AppState

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )

                Text("Loading...")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            isAnimating = true
            decideStartDestination()
        }
    }

    // MARK: - Stored choice

    /// Читает сохранённый выбор модуля из UserDefaults.
    private func storedModuleChoice() -> AppStartDestination? {
        let value = UserDefaults.standard.string(forKey: DefaultsKeys.moduleChoice)
        switch value {
        case "module1": return .module1
        case "module2": return .module2
        default: return nil
        }
    }

    /// Сохраняет выбор модуля в UserDefaults.
    private func saveModuleChoice(_ destination: AppStartDestination) {
        switch destination {
        case .module1:
            UserDefaults.standard.set("module1", forKey: DefaultsKeys.moduleChoice)
        case .module2:
            UserDefaults.standard.set("module2", forKey: DefaultsKeys.moduleChoice)
        case .splash:
            break
        }
    }

    // MARK: - Routing logic

    /// Решает, куда перейти после сплэша.
    private func decideStartDestination() {
        // 1. Проверяем, есть ли уже сохранённое решение.
        if let saved = storedModuleChoice() {
            appState.startDestination = saved
            return
        }

        // 2. Если решения нет — это первый запуск, качаем JSON.
        Task {
            let destination = await fetchRemoteConfigAndDecide()
            saveModuleChoice(destination)
            await MainActor.run {
                appState.startDestination = destination
            }
        }
    }

    /// Качает конфиг и решает, какой модуль показать.
    private func fetchRemoteConfigAndDecide() async -> AppStartDestination {
        // URL из ТЗ.
        guard let url = URL(string: "https://drive.google.com/uc?export=download&id=13935lF1Cs8cRQOYRp6pnkK-TalBW5EyU") else {
            // Ошибка формирования URL -> модуль 1.
            return .module1
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let config = try JSONDecoder().decode(RemoteConfig.self, from: data)

            // Проверяем, что ссылка валидна и не пустая.
            guard URL(string: config.url) != nil, !config.url.isEmpty else {
                return .module1
            }

            // Ссылка валидна, сохраняем как последнюю web‑страницу.
            UserDefaults.standard.set(config.url, forKey: DefaultsKeys.lastWebURL)

            // По ТЗ: валидная ссылка -> модуль 2.
            return .module2
        } catch {
            // Любая ошибка сети/парсинга -> модуль 1.
            return .module1
        }
    }
}
