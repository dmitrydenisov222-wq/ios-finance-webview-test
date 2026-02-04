import SwiftUI

/// Корневой экран модуля 2:
/// полноэкранный WebView с игнором safe area.
struct Module2RootView: View {
    var body: some View {
        WebViewContainer()
            .ignoresSafeArea()
    }
}
