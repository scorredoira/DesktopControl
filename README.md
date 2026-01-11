# DesktopControl

A lightweight macOS menu bar app for quick access to system controls.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- **Theme Switching**: Toggle between Light and Dark mode (affects macOS, Terminal, and VS Code)
- **Brightness Control**: Adjust screen brightness with a slider
- **Volume Control**: Adjust system volume with a slider (click speaker icon to mute)
- **Shortcuts Reference**: Quick reminder of useful keyboard shortcuts

## Screenshot

The app appears as a floating panel in the center of the screen, accessible via `Option + Space` or by clicking the menu bar icon.

## Installation

### Build from source

```bash
git clone https://github.com/scorredoira/DesktopControl.git
cd DesktopControl
swift build -c release
cp -r .build/release/DesktopControl ~/Applications/
```

### Auto-start on login

Create a Launch Agent to start the app automatically:

```bash
cat > ~/Library/LaunchAgents/com.local.DesktopControl.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.DesktopControl</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USERNAME/Applications/DesktopControl.app/Contents/MacOS/DesktopControl</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/com.local.DesktopControl.plist
```

## Usage

- **Option + Space**: Toggle the control panel
- Click the menu bar icon (grid icon) to open

## Keyboard Shortcuts Reference

The app displays these useful macOS shortcuts:

| Shortcut | Action |
|----------|--------|
| Option + Space | Open/close this panel |
| F18 | Handy |
| Ctrl + 1-4 | Switch to desktop 1-4 |
| Ctrl + Left/Right | Previous/next desktop |
| F11 | Show desktop |
| Ctrl + Up | Mission Control |

## Requirements

- macOS 13.0 or later
- Swift 5.9+

## License

MIT
