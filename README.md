# Claude Status Bar

A tiny native macOS menu bar app that shows the live status of [status.claude.com](https://status.claude.com) at a glance. Faster than wondering whether *it's me or it's Claude* and then opening a browser tab.

[![macOS](https://img.shields.io/badge/macOS-14%2B-blue)](#requirements)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](#)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/robbertvancaem/claude-status-bar?label=release)](https://github.com/robbertvancaem/claude-status-bar/releases)
[![Downloads](https://img.shields.io/github/downloads/robbertvancaem/claude-status-bar/total.svg?label=downloads)](https://github.com/robbertvancaem/claude-status-bar/releases)

## Install

```bash
brew install robbertvancaem/tap/claude-status-bar
open "/Applications/Claude Status Bar.app"
```

That's it. No Apple Developer cert, no `xattr` dance — the cask strips the quarantine flag for you on install.

To launch on login: drag `/Applications/Claude Status Bar.app` into **System Settings → General → Login Items**.

### Updating

```bash
brew upgrade --cask claude-status-bar
```

## What it does

- Polls `status.claude.com` every 10 seconds.
- Shows a single SF Symbol (`sparkles`) in the menu bar:
  - **Operational** — rendered as a template icon, adopting the macOS menu bar theme (white in dark mode, black in light mode). Blends in like a native icon when there's nothing to worry about.
  - **Minor / Major / Critical** — colored sparkle (yellow / orange / red) at 50% opacity, drawing just enough attention without being aggressive.
- Click the icon for a per-component breakdown (claude.ai, Console, API, Claude Code, Cowork, Government).
- Optional native macOS notification on state transitions (e.g. operational → minor). Toggleable from the dropdown.

No usage tracking, no Claude Code session monitoring, no settings UI to wade through. Just up/down.

## Build from source

If you'd rather build it yourself (no Homebrew dependency):

```bash
git clone https://github.com/robbertvancaem/claude-status-bar.git
cd claude-status-bar
./build.sh
open "/Applications/Claude Status Bar.app"
```

Needs Xcode Command Line Tools (`xcode-select --install`) and macOS 14+. The build script compiles a release binary via Swift Package Manager and drops the `.app` bundle into `/Applications/`. Re-running `build.sh` updates the binary in place (ad-hoc signed).

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

## Requirements

macOS 14 (Sonoma) or later.

## License

MIT — see [LICENSE](LICENSE).

## Not affiliated with Anthropic

This is an unofficial tool. "Claude" and "Anthropic" are trademarks of Anthropic. The app only reads the public status page that Anthropic publishes for everyone.
