import Foundation

struct PMSetController {
    static let pmsetPath = "/usr/bin/pmset"

    /// Runs the real `sudo pmset ...` command so CyberArk EPM's sudo hook fires
    /// (its browser-based approval flow), same as running it manually in Terminal.
    /// This blocks until the user approves/denies in the browser, so it must be
    /// called off the main thread.
    @discardableResult
    static func setDisableSleepWithPrompt(_ disabled: Bool) -> Bool {
        let value = disabled ? "1" : "0"

        // Run inside a pty so sudo/CyberArk's hook sees a TTY, matching Terminal behavior.
        let scriptTask = Process()
        scriptTask.executableURL = URL(fileURLWithPath: "/usr/bin/script")
        scriptTask.arguments = ["-q", "/dev/null", "/usr/bin/sudo", pmsetPath, "-a", "disablesleep", value]

        let pipe = Pipe()
        scriptTask.standardError = pipe
        scriptTask.standardOutput = pipe
        do {
            try scriptTask.run()
            scriptTask.waitUntilExit()
            return scriptTask.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// Reads current disablesleep state from `pmset -g`.
    static func currentlyDisabled() -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: pmsetPath)
        task.arguments = ["-g"]
        let pipe = Pipe()
        task.standardOutput = pipe
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            let output = String(data: data, encoding: .utf8) ?? ""
            for line in output.split(separator: "\n") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("SleepDisabled") {
                    return trimmed.hasSuffix("1")
                }
            }
        } catch {
            return false
        }
        return false
    }
}
