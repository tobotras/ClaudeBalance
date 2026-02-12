# ClaudeBalance

A lightweight macOS menu bar widget that displays your Anthropic API credit balance.

## Build

```bash
./build.sh
```

Requires Xcode Command Line Tools (`xcode-select --install`).

## Run

```bash
open build/ClaudeBalance.app
```

On first launch you have to
1. configure your organization ID and
2. log in to your Anthropic account.
After that the balance (e.g. `$15.02`) appears in the menu bar and refreshes every 5 minutes.

## Menu bar options

- **Refresh Now** (Cmd+R) — re-fetch the balance immediately
- **Log In to Anthropic...** (Cmd+L) — re-open the login window if your session expires
- **Quit** (Cmd+Q)

## Auto-start on login

System Settings → General → Login Items → add `ClaudeBalance.app`.
