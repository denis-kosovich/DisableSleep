import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var toggleMenuItem: NSMenuItem!
    private var statusMenuItem: NSMenuItem!

    private var sleepDisabled = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let menu = NSMenu()

        statusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())

        toggleMenuItem = NSMenuItem(title: "", action: #selector(toggleSleep), keyEquivalent: "")
        toggleMenuItem.target = self
        menu.addItem(toggleMenuItem)
        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu

        sleepDisabled = PMSetController.currentlyDisabled()
        refreshUI()
    }

    @objc private func toggleSleep() {
        let wantDisabled = !sleepDisabled

        toggleMenuItem.isEnabled = false
        statusMenuItem.title = "Waiting for approval…"
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "Waiting for approval")
            button.image?.isTemplate = true
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let success = PMSetController.setDisableSleepWithPrompt(wantDisabled)
            DispatchQueue.main.async {
                guard let self else { return }
                if success {
                    self.sleepDisabled = wantDisabled
                } else {
                    self.showAlert("Failed to change sleep settings. The approval request may have been denied or timed out.")
                }
                self.toggleMenuItem.isEnabled = true
                self.refreshUI()
            }
        }
    }

    private func refreshUI() {
        sleepDisabled = PMSetController.currentlyDisabled()

        if let button = statusItem.button {
            if sleepDisabled {
                button.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "Sleep Disabled")
                button.image?.isTemplate = true
            } else {
                button.image = Icons.eyeClosed
            }
        }

        statusMenuItem.title = sleepDisabled ? "Sleep: Disabled" : "Sleep: Enabled (normal)"
        toggleMenuItem.title = sleepDisabled ? "Re-enable Sleep" : "Disable Sleep"
    }

    private func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Disable Sleep"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
