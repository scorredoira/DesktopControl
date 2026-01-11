import Foundation
import Cocoa

class BrightnessController: ObservableObject {
    @Published var brightness: Float = 0.5

    init() {
        updateCurrentBrightness()
    }

    func updateCurrentBrightness() {
        // Try IOKit first
        if let value = getBrightnessIOKit() {
            DispatchQueue.main.async {
                self.brightness = value
            }
            return
        }

        // Try DisplayServices
        if let value = getBrightnessDisplayServices() {
            DispatchQueue.main.async {
                self.brightness = value
            }
        }
    }

    private func getBrightnessIOKit() -> Float? {
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )

        guard result == kIOReturnSuccess else { return nil }

        var brightness: Float?
        var service: io_object_t = IOIteratorNext(iterator)
        while service != 0 {
            var brightnessValue: Float = 0
            let err = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightnessValue)
            if err == kIOReturnSuccess && brightnessValue > 0 {
                brightness = brightnessValue
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)

        return brightness
    }

    private func getBrightnessDisplayServices() -> Float? {
        typealias GetBrightnessFunc = @convention(c) (UInt32, UnsafeMutablePointer<Float>) -> Int32

        guard let handle = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_NOW) else {
            return nil
        }
        defer { dlclose(handle) }

        guard let sym = dlsym(handle, "DisplayServicesGetBrightness") else {
            return nil
        }

        let getBrightness = unsafeBitCast(sym, to: GetBrightnessFunc.self)
        let displayID = CGMainDisplayID()

        var brightness: Float = 0
        let result = getBrightness(displayID, &brightness)

        return result == 0 ? brightness : nil
    }

    func setBrightness(_ value: Float) {
        // Try DisplayServices first (works on Apple Silicon)
        if setBrightnessDisplayServices(value) {
            return
        }

        // Try IOKit
        if setBrightnessIOKit(value) {
            return
        }
    }

    private func setBrightnessDisplayServices(_ value: Float) -> Bool {
        typealias SetBrightnessFunc = @convention(c) (UInt32, Float) -> Int32

        guard let handle = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_NOW) else {
            return false
        }
        defer { dlclose(handle) }

        guard let sym = dlsym(handle, "DisplayServicesSetBrightness") else {
            return false
        }

        let setBrightness = unsafeBitCast(sym, to: SetBrightnessFunc.self)
        let displayID = CGMainDisplayID()

        let result = setBrightness(displayID, value)
        return result == 0
    }

    private func setBrightnessIOKit(_ value: Float) -> Bool {
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IODisplayConnect"),
            &iterator
        )

        guard result == kIOReturnSuccess else { return false }

        var success = false
        var service: io_object_t = IOIteratorNext(iterator)
        while service != 0 {
            let err = IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, value)
            if err == kIOReturnSuccess {
                success = true
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)

        return success
    }
}
