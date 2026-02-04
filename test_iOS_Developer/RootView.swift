import SwiftUI

/// Корневой роутер по состоянию приложения.
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.startDestination {
        case .splash:
            SplashView()
        case .module1:
            Module1RootView()
        case .module2:
            Module2RootView()
        }
    }
}
