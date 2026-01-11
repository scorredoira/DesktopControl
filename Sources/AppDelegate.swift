import Cocoa
import SwiftUI
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var popoverWindow: NSWindow?
    private var hotKeyRef: EventHotKeyRef?
    private var isWindowVisible = false

    // Shared controllers
    static var volumeController = VolumeController()
    static var brightnessController = BrightnessController()
    static var themeController = ThemeController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupHotKey()
        setupWindow()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "Desktop Control")
            button.action = #selector(toggleWindow)
            button.target = self
        }
    }

    private func setupWindow() {
        let contentView = ContentView()

        popoverWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 440),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        popoverWindow?.contentView = NSHostingView(rootView: contentView)
        popoverWindow?.backgroundColor = .clear
        popoverWindow?.isOpaque = false
        popoverWindow?.hasShadow = true
        popoverWindow?.level = .floating
        popoverWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        popoverWindow?.isMovableByWindowBackground = true
    }

    private func setupHotKey() {
        // Register Option + Space hotkey
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4454_4350) // "DTCP"
        hotKeyID.id = 1

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        // Install event handler
        InstallEventHandler(GetApplicationEventTarget(), { (_, event, _) -> OSStatus in
            NotificationCenter.default.post(name: .toggleWindow, object: nil)
            return noErr
        }, 1, &eventType, nil, nil)

        // Option + Space: modifier = optionKey (0x0800), keycode = 49 (space)
        let modifiers: UInt32 = UInt32(optionKey)
        let keyCode: UInt32 = 49 // Space key

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(toggleWindow),
            name: .toggleWindow,
            object: nil
        )
    }

    @objc func toggleWindow() {
        if isWindowVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }

    private func showWindow() {
        guard let window = popoverWindow else { return }

        // Center on screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = window.frame
            let x = screenFrame.midX - windowFrame.width / 2
            let y = screenFrame.midY - windowFrame.height / 2
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isWindowVisible = true
    }

    private func hideWindow() {
        popoverWindow?.orderOut(nil)
        isWindowVisible = false
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}

extension Notification.Name {
    static let toggleWindow = Notification.Name("toggleWindow")
}
