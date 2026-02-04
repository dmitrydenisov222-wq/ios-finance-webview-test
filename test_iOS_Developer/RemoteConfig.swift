import Foundation

/// Конфигурация, полученная с сервера (например, JSON вида `{ "url": "https://..." }`).
struct RemoteConfig: Decodable {
    /// Строка с URL, куда должен вести модуль 2.
    let url: String
}
