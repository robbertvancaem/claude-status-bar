import Foundation
import SwiftUI
import UserNotifications

struct StatusResponse: Decodable {
    struct Page: Decodable { let updated_at: String }
    struct Status: Decodable { let indicator: String; let description: String }
    let page: Page
    let status: Status
}

struct ComponentsResponse: Decodable {
    struct Component: Decodable, Identifiable {
        let id: String
        let name: String
        let status: String
        let position: Int
    }
    let components: [Component]
}

@MainActor
final class StatusModel: ObservableObject {
    @Published var indicator: String = "loading"
    @Published var statusDescription: String = "Loading..."
    @Published var components: [ComponentsResponse.Component] = []
    @Published var lastUpdated: Date?
    @Published var lastError: String?
    @Published var notificationsEnabled: Bool = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    private var timer: Timer?
    private let pollInterval: TimeInterval = 10
    private var previousIndicator: String?

    private let statusURL = URL(string: "https://status.claude.com/api/v2/status.json")!
    private let componentsURL = URL(string: "https://status.claude.com/api/v2/components.json")!

    init() {
        Task { await poll() }
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.poll() }
        }
    }

    func poll() async {
        do {
            async let statusFetch: StatusResponse = fetch(statusURL)
            async let componentsFetch: ComponentsResponse = fetch(componentsURL)
            let (status, comps) = try await (statusFetch, componentsFetch)

            let newIndicator = status.status.indicator
            if let prev = previousIndicator, prev != newIndicator, notificationsEnabled {
                notifyTransition(from: prev, to: newIndicator, description: status.status.description)
            }
            previousIndicator = newIndicator

            self.indicator = newIndicator
            self.statusDescription = status.status.description
            self.components = comps.components.sorted { $0.position < $1.position }
            self.lastUpdated = Date()
            self.lastError = nil
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    private func fetch<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 8
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func notifyTransition(from: String, to: String, description: String) {
        let content = UNMutableNotificationContent()
        content.title = "Claude status: \(label(for: to))"
        content.body = description
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    var iconName: String {
        switch indicator {
        case "none": return "circle.fill"
        case "minor": return "exclamationmark.circle.fill"
        case "major": return "exclamationmark.triangle.fill"
        case "critical": return "xmark.octagon.fill"
        default: return "circle.dotted"
        }
    }

    var iconColor: Color {
        color(for: indicator)
    }

    func color(for indicator: String) -> Color {
        switch indicator {
        case "none": return .green
        case "minor": return .yellow
        case "major": return .orange
        case "critical": return .red
        default: return .gray
        }
    }

    func label(for indicator: String) -> String {
        switch indicator {
        case "none": return "All systems operational"
        case "minor": return "Minor issue"
        case "major": return "Major outage"
        case "critical": return "Critical outage"
        default: return "Unknown"
        }
    }

    func colorForComponentStatus(_ status: String) -> Color {
        switch status {
        case "operational": return .green
        case "degraded_performance": return .yellow
        case "partial_outage": return .orange
        case "major_outage": return .red
        case "under_maintenance": return .blue
        default: return .gray
        }
    }
}
