import SwiftUI
import WebKit

// MARK: - SwiftUI контейнер для WebViewController

struct WebViewContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> WebViewController {
        WebViewController()
    }

    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        // Нет динамических обновлений из SwiftUI.
    }
}

// MARK: - UIKit контроллер с WKWebView

final class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private let webView = WKWebView(
        frame: .zero,
        configuration: {
            let config = WKWebViewConfiguration()
            config.websiteDataStore = .default()          // сохраняем cookies/сессию [web:223]
            config.allowsInlineMediaPlayback = true
            config.mediaTypesRequiringUserActionForPlayback = []
            return config
        }()
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        setupGestures()
        loadInitialURL()
    }

    // MARK: - Initial URL

    private func loadInitialURL() {
        // Берём последнюю сохранённую страницу.
        if let last = UserDefaults.standard.string(forKey: DefaultsKeys.lastWebURL),
           let url = URL(string: last) {
            webView.load(URLRequest(url: url))
        }
    }

    // MARK: - Gestures

    private func setupGestures() {
        // Свайп вправо/влево для назад/вперёд.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left

        webView.addGestureRecognizer(swipeRight)
        webView.addGestureRecognizer(swipeLeft)

        // Пан сверху вниз для обновления.
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        webView.addGestureRecognizer(pan)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            if webView.canGoBack {
                webView.goBack()
            }
        case .left:
            if webView.canGoForward {
                webView.goForward()
            }
        default:
            break
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: webView)
        if gesture.state == .ended, translation.y > 80 {
            webView.reload()
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Каждый раз при завершении загрузки сохраняем последнюю URL.
        if let url = webView.url?.absoluteString {
            UserDefaults.standard.set(url, forKey: DefaultsKeys.lastWebURL)
        }
    }

    // MARK: - WKUIDelegate (обработка target="_blank")

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil {
            // Открываем ссылки с target="_blank" в текущем webView. [web:221]
            webView.load(navigationAction.request)
        }
        return nil
    }

    // MARK: - Orientation

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscapeLeft, .landscapeRight]
    }
}

// Нужно, чтобы pan‑жест не ломал другие жесты webView.
extension WebViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
