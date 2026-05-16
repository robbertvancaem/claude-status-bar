# Claude Status Bar

A tiny native macOS menu bar app that shows a coloured dot reflecting the live status of [status.claude.com](https://status.claude.com). Faster than wondering whether *it's me or it's Claude* and then opening a browser tab.

![macOS](https://img.shields.io/badge/macOS-14%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## What it does

- Polls `status.claude.com` every 10 seconds.
- Shows a single SF Symbol in the menu bar:
  - 🟢 green — all systems operational
  - 🟡 yellow — minor issue
  - 🟠 orange — major outage
  - 🔴 red — critical outage
- Click the icon for a per-component breakdown (claude.ai, Console, API, Claude Code, Cowork, Government).
- Optional native macOS notification on state transitions (e.g. green → yellow). Toggleable.

No usage tracking, no Claude Code session monitoring, no settings UI to wade through. Just up/down.

## Install

### Requirements

- macOS 14 (Sonoma) or later
- Xcode Command Line Tools (`xcode-select --install`)

### Build

```bash
git clone https://github.com/robbertvancaem/claude-status-bar.git
cd claude-status-bar
./build.sh
open "/Applications/Claude Status Bar.app"
```

The build script compiles a release binary via Swift Package Manager and drops the `.app` bundle into `/Applications/`. Re-running `build.sh` updates the binary in place (ad-hoc signed).

To launch on login: drag `/Applications/Claude Status Bar.app` into **System Settings → General → Login Items**.

## Architecture

A single-file SwiftUI `MenuBarExtra` app:

| File | Purpose |
|------|---------|
| `Sources/App.swift` | Entry point + menu bar icon |
| `Sources/StatusModel.swift` | Polls Statuspage v2 endpoints, decodes, holds state |
| `Sources/StatusViews.swift` | Dropdown menu content |
| `build.sh` | Build & install (Swift Package Manager → `.app` bundle) |

The Statuspage v2 API (`/api/v2/status.json` + `/api/v2/components.json`) is public and unauthenticated, so the app makes plain `URLSession` requests every 10 seconds and parses with `Codable`.

## Configuration

There isn't really any. The poll interval is hard-coded to 10 seconds — fast enough to catch a status change before you finish swearing at your terminal, slow enough that `status.claude.com` won't blink.

The only toggle exposed is **Notify on status changes**, persisted in `UserDefaults`.

## License

MIT — see [LICENSE](LICENSE).

## Not affiliated with Anthropic

This is an unofficial tool. "Claude" and "Anthropic" are trademarks of Anthropic. The app only reads the public status page that Anthropic publishes for everyone.
