import SwiftUI

@main
struct test_iOS_DeveloperApp: App {
    /// Глобальное состояние приложения, доступно во всей иерархии через EnvironmentObject.
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
