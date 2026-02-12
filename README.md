# ClaudeBalance

A lightweight macOS menu bar app that displays your Anthropic API credit balance.

## Build

```bash
./build.sh
```

Requires Xcode Command Line Tools (`xcode-select --install`).

## Run

```bash
open build/ClaudeBalance.app
```

On first launch a browser window opens — log in to your Anthropic account. After that the balance (e.g. `$15.02`) appears in the menu bar and refreshes every 5 minutes.

## Menu bar options

- **Refresh Now** (Cmd+R) — re-fetch the balance immediately
- **Log In to Anthropic...** (Cmd+L) — re-open the login window if your session expires
- **Quit** (Cmd+Q)

## Configuration

Edit the constants at the top of `Sources/main.swift`:

| Constant | Description |
|---|---|
| `kOrgID` | Your Anthropic organization ID |
| `kRefreshSeconds` | Polling interval in seconds (default: 300) |

## Auto-start on login

System Settings → General → Login Items → add `ClaudeBalance.app`.
