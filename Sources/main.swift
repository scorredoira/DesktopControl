import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Required for menu bar apps to work properly
app.setActivationPolicy(.accessory)

app.run()
