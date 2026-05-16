import SwiftUI

struct StatusMenuView: View {
    @ObservedObject var model: StatusModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            Divider()

            if model.components.isEmpty {
                Text("Loading components…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.components) { component in
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(model.colorForComponentStatus(component.status))
                            .font(.system(size: 8))
                        Text(component.name)
                            .font(.system(size: 12))
                        Spacer()
                        Text(humanise(component.status))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()

            footer
        }
        .padding(12)
        .frame(width: 320)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: model.iconName)
                .foregroundStyle(model.iconColor)
                .opacity(model.iconOpacity)
                .font(.system(size: 14, weight: .semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text(model.label(for: model.indicator))
                    .font(.system(size: 13, weight: .semibold))
                Text(model.statusDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let error = model.lastError {
                Text("Error: \(error)")
                    .font(.caption2)
                    .foregroundStyle(.red)
            } else if let updated = model.lastUpdated {
                Text("Updated \(relative(updated))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Toggle("Notify on status changes", isOn: $model.notificationsEnabled)
                .toggleStyle(.checkbox)
                .font(.caption)

            HStack {
                Button("Open status page") {
                    if let url = URL(string: "https://status.claude.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderless)
                .font(.caption)

                Spacer()

                Button("Refresh") {
                    Task { await model.poll() }
                }
                .buttonStyle(.borderless)
                .font(.caption)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
        }
    }

    private func humanise(_ status: String) -> String {
        status.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func relative(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
