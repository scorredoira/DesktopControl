import Foundation
import CoreAudio
import Combine

// Define the constant that's in AudioToolbox but not exposed to Swift
private let kAudioHardwareServiceDeviceProperty_VirtualMainVolume: AudioObjectPropertySelector = 0x766D7663 // 'vmvc'

class VolumeController: ObservableObject {
    @Published var volume: Float = 0.5
    @Published var isMuted: Bool = false

    private var defaultOutputDeviceID: AudioDeviceID = kAudioObjectUnknown

    init() {
        setupDefaultOutputDevice()
        updateCurrentVolume()
        updateMuteStatus()
    }

    private func setupDefaultOutputDevice() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioDeviceID = kAudioObjectUnknown
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )

        if status == noErr {
            defaultOutputDeviceID = deviceID
        }
    }

    func updateCurrentVolume() {
        guard defaultOutputDeviceID != kAudioObjectUnknown else { return }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var volume: Float32 = 0
        var propertySize = UInt32(MemoryLayout<Float32>.size)

        let status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &volume
        )

        if status == noErr {
            DispatchQueue.main.async {
                self.volume = volume
            }
        }
    }

    func setVolume(_ newVolume: Float) {
        guard defaultOutputDeviceID != kAudioObjectUnknown else { return }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var volume = newVolume
        let propertySize = UInt32(MemoryLayout<Float32>.size)

        AudioObjectSetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            propertySize,
            &volume
        )

        // Unmute if setting volume
        if newVolume > 0 && isMuted {
            setMute(false)
        }
    }

    func updateMuteStatus() {
        guard defaultOutputDeviceID != kAudioObjectUnknown else { return }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var muted: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectGetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &muted
        )

        if status == noErr {
            DispatchQueue.main.async {
                self.isMuted = muted != 0
            }
        }
    }

    func setMute(_ mute: Bool) {
        guard defaultOutputDeviceID != kAudioObjectUnknown else { return }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var muted: UInt32 = mute ? 1 : 0
        let propertySize = UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectSetPropertyData(
            defaultOutputDeviceID,
            &propertyAddress,
            0,
            nil,
            propertySize,
            &muted
        )

        if status == noErr {
            DispatchQueue.main.async {
                self.isMuted = mute
            }
        }
    }

    func toggleMute() {
        setMute(!isMuted)
    }
}
