import Cocoa
import WebKit

// ── Configuration ───────────────────────────────────────────────
let kRefreshSeconds  = 300.0   // 5 minutes
let kDefaultsOrgKey  = "orgID"
// ────────────────────────────────────────────────────────────────

let kLoginURL = URL(string: "https://platform.claude.com/settings/billing")!

func creditsURL(orgID: String) -> URL {
    URL(string: "https://platform.claude.com/api/organizations/\(orgID)/prepaid/credits")!
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?
    var loginWindow: NSWindow?
    var webView: WKWebView!
    var isLoggedIn = false

    var orgID: String {
        get { UserDefaults.standard.string(forKey: kDefaultsOrgKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: kDefaultsOrgKey) }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        webView = WKWebView(frame: .zero, configuration: config)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "$…"
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(
            ofSize: NSFont.systemFontSize, weight: .regular)

        rebuildMenu()

        if orgID.isEmpty {
            showOrgPrompt()
        } else {
            fetchCredits()
        }

        timer = Timer.scheduledTimer(timeInterval: kRefreshSeconds,
                                     target: self,
                                     selector: #selector(fetchCredits),
                                     userInfo: nil,
                                     repeats: true)
    }

    // MARK: - Menu

    func rebuildMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh Now",
                                action: #selector(fetchCredits),
                                keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Log In to Anthropic…",
                                action: #selector(showLogin),
                                keyEquivalent: "l"))
        menu.addItem(NSMenuItem(title: "Set Organization ID…",
                                action: #selector(showOrgPrompt),
                                keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))
        statusItem.menu = menu
    }

    // MARK: - Org ID prompt

    @objc func showOrgPrompt() {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "Organization ID"
        alert.informativeText = "Find it in the URL after logging in:\nplatform.claude.com/settings/billing\n→ /organizations/<this-id>/…"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 340, height: 24))
        field.stringValue = orgID
        field.placeholderString = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        alert.accessoryView = field
        alert.window.initialFirstResponder = field

        if alert.runModal() == .alertFirstButtonReturn {
            let value = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty {
                orgID = value
                fetchCredits()
            }
        }
    }

    // MARK: - Login window

    @objc func showLogin() {
        if let w = loginWindow {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
                         styleMask: [.titled, .closable, .resizable],
                         backing: .buffered, defer: false)
        w.title = "Log in to Anthropic"
        w.center()
        w.contentView = webView
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        loginWindow = w

        webView.load(URLRequest(url: kLoginURL))
    }

    // MARK: - Fetch balance

    @objc func fetchCredits() {
        guard !orgID.isEmpty else { return }

        let url = creditsURL(orgID: orgID)
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let header = cookies
                .filter { url.host?.contains($0.domain.dropFirst()) == true || $0.domain == url.host }
                .map { "\($0.name)=\($0.value)" }
                .joined(separator: "; ")
            request.setValue(header, forHTTPHeaderField: "Cookie")

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async { self.handleResponse(data, response, error) }
            }.resume()
        }
    }

    private func handleResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        if let error = error {
            NSLog("Fetch error: %@", error.localizedDescription)
            statusItem.button?.title = "$ERR"
            return
        }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let cents = json["amount"] as? Int else {
            statusItem.button?.title = "$--"
            if !isLoggedIn { showLogin() }
            return
        }
        isLoggedIn = true
        let dollars = Double(cents) / 100.0
        statusItem.button?.title = String(format: "$%.2f", dollars)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
