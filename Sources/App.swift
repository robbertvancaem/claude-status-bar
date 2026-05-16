import SwiftUI
import UserNotifications

@main
struct ClaudeStatusBarApp: App {
    @StateObject private var model = StatusModel()

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    var body: some Scene {
        MenuBarExtra {
            StatusMenuView(model: model)
        } label: {
            Image(systemName: model.iconName)
                .renderingMode(.original)
                .foregroundStyle(model.iconColor)
                .opacity(model.iconOpacity)
        }
        .menuBarExtraStyle(.window)
    }
}
