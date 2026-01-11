import SwiftUI

struct ContentView: View {
    @StateObject private var volumeController = AppDelegate.volumeController
    @StateObject private var brightnessController = AppDelegate.brightnessController
    @StateObject private var themeController = AppDelegate.themeController

    var body: some View {
        VStack(spacing: 16) {
            // Theme buttons
            HStack(spacing: 12) {
                Button(action: {
                    themeController.setLightMode()
                }) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                        Text("Light")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(!themeController.isDarkMode ? Color.accentColor : Color.gray.opacity(0.3))
                    .foregroundColor(!themeController.isDarkMode ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button(action: {
                    themeController.setDarkMode()
                }) {
                    HStack {
                        Image(systemName: "moon.fill")
                        Text("Dark")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(themeController.isDarkMode ? Color.accentColor : Color.gray.opacity(0.3))
                    .foregroundColor(themeController.isDarkMode ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Brightness slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                    Text("Brillo")
                    Spacer()
                    Text("\(Int(brightnessController.brightness * 100))%")
                        .foregroundColor(.secondary)
                }

                Slider(value: $brightnessController.brightness, in: 0...1)
                    .onChange(of: brightnessController.brightness) { newValue in
                        brightnessController.setBrightness(newValue)
                    }
            }

            // Volume slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: volumeController.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            volumeController.toggleMute()
                        }
                    Text("Volumen")
                    Spacer()
                    Text("\(Int(volumeController.volume * 100))%")
                        .foregroundColor(.secondary)
                }

                Slider(value: $volumeController.volume, in: 0...1)
                    .onChange(of: volumeController.volume) { newValue in
                        volumeController.setVolume(newValue)
                    }
            }

            Divider()

            // Shortcuts list
            VStack(alignment: .leading, spacing: 6) {
                Text("Atajos")
                    .font(.headline)
                    .foregroundColor(.secondary)

                ShortcutRow(keys: "Option + Space", description: "Abrir/cerrar este panel")
                ShortcutRow(keys: "F18", description: "Handy")
                ShortcutRow(keys: "Ctrl + 1-4", description: "Cambiar a escritorio 1-4")
                ShortcutRow(keys: "Ctrl + Izq/Der", description: "Escritorio anterior/siguiente")
                ShortcutRow(keys: "F11", description: "Mostrar escritorio")
                ShortcutRow(keys: "Ctrl + Arriba", description: "Mission Control")
            }

            Spacer()

            // Quit button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Salir")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .padding(20)
        .frame(width: 320, height: 440)
        .background(VisualEffectView())
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ShortcutRow: View {
    let keys: String
    let description: String

    var body: some View {
        HStack {
            Text(keys)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
