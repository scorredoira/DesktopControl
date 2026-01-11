import Foundation
import AppKit

class ThemeController: ObservableObject {
    @Published var isDarkMode: Bool = false

    init() {
        // Check current mode asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            self.updateCurrentMode()
        }
    }

    func updateCurrentMode() {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "tell app \"System Events\" to tell appearance preferences to get dark mode"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DispatchQueue.main.async {
                    self.isDarkMode = output == "true"
                }
            }
        } catch {
            print("Error checking dark mode: \(error)")
        }
    }

    func setDarkMode() {
        DispatchQueue.global(qos: .userInitiated).async {
            // 1. macOS dark mode
            self.runOsascript("tell app \"System Events\" to tell appearance preferences to set dark mode to true")

            // 2. Terminal colors
            self.setTerminalColors(dark: true)

            // 3. VS Code theme
            self.setVSCodeTheme(dark: true)

            DispatchQueue.main.async {
                self.isDarkMode = true
            }
        }
    }

    func setLightMode() {
        DispatchQueue.global(qos: .userInitiated).async {
            // 1. macOS light mode
            self.runOsascript("tell app \"System Events\" to tell appearance preferences to set dark mode to false")

            // 2. Terminal colors
            self.setTerminalColors(dark: false)

            // 3. VS Code theme
            self.setVSCodeTheme(dark: false)

            DispatchQueue.main.async {
                self.isDarkMode = false
            }
        }
    }

    private func setTerminalColors(dark: Bool) {
        let bgColor: String
        let txtColor: String

        if dark {
            bgColor = "{0, 0, 0}"
            txtColor = "{65535, 65535, 65535}"
        } else {
            bgColor = "{65535, 65535, 65535}"
            txtColor = "{0, 0, 0}"
        }

        let script = """
        tell application "Terminal"
            set bgColor to \(bgColor)
            set txtColor to \(txtColor)
            set cursorColor to \(txtColor)
            repeat with w in windows
                try
                    repeat with t in tabs of w
                        set background color of current settings of t to bgColor
                        set normal text color of current settings of t to txtColor
                        set cursor color of current settings of t to cursorColor
                        set font name of current settings of t to "SF Mono Regular"
                        set font size of current settings of t to 13
                    end repeat
                end try
            end repeat
        end tell
        """
        runOsascript(script)
    }

    private func setVSCodeTheme(dark: Bool) {
        let settingsPath = NSString(string: "~/Library/Application Support/Code/User/settings.json").expandingTildeInPath
        let themeName = dark ? "Default Dark Modern" : "Default Light Modern"

        var settings: [String: Any] = [:]

        // Read existing settings
        if let data = FileManager.default.contents(atPath: settingsPath),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            settings = json
        }

        // Update theme
        settings["workbench.colorTheme"] = themeName

        // Write back
        if let data = try? JSONSerialization.data(withJSONObject: settings, options: [.prettyPrinted, .sortedKeys]) {
            // Create directory if needed
            let dirPath = (settingsPath as NSString).deletingLastPathComponent
            try? FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true)
            try? data.write(to: URL(fileURLWithPath: settingsPath))
        }
    }

    private func runOsascript(_ script: String) {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("osascript error: \(error)")
        }
    }
}
