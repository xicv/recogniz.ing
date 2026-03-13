import Cocoa
import FlutterMacOS

/// Push-to-Talk service using CGEventTap to monitor modifier key press/release.
///
/// Monitors device-dependent flags to distinguish left vs right modifiers
/// (e.g., Right Command vs Left Command). Streams "keyDown"/"keyUp" events
/// to Dart via FlutterEventChannel.
class PttEventTapService: NSObject, FlutterStreamHandler {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var eventSink: FlutterEventSink?
    private var monitoredKey: String = "rightCommand"
    private var tapThread: Thread?
    private var isKeyDown: Bool = false
    private var isMonitoring: Bool = false

    // Device-dependent flag masks (from IOKit/IOLLEvent.h)
    // These are in the upper 16 bits of the raw flags
    private static let NX_DEVICELCMDKEYMASK: UInt64  = 0x00000008  // bit 3 of device flags
    private static let NX_DEVICERCMDKEYMASK: UInt64  = 0x00000010  // bit 4 of device flags
    private static let NX_DEVICELALTKEYMASK: UInt64  = 0x00000020  // bit 5 of device flags
    private static let NX_DEVICERALTKEYMASK: UInt64  = 0x00000040  // bit 6 of device flags

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if isMonitoring {
            startTap()
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        stopTap()
        return nil
    }

    // MARK: - Public API

    func setMonitoredKey(_ key: String) {
        monitoredKey = key
        // Reset state when key changes
        isKeyDown = false
    }

    func startMonitoring() {
        isMonitoring = true
        if eventSink != nil {
            startTap()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        stopTap()
        // If key was held when we stopped, send keyUp
        if isKeyDown {
            isKeyDown = false
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?("keyUp")
            }
        }
    }

    // MARK: - Event Tap

    private func startTap() {
        // Already running
        if eventTap != nil { return }

        // We need a reference to self for the C callback
        let refToSelf = Unmanaged.passRetained(self)

        // Create event tap for flagsChanged events (modifier key state changes)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(1 << CGEventType.flagsChanged.rawValue),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let service = Unmanaged<PttEventTapService>.fromOpaque(refcon).takeUnretainedValue()
                service.handleFlagsChanged(event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: refToSelf.toOpaque()
        ) else {
            NSLog("[PTT] Failed to create event tap — accessibility permission may be missing")
            refToSelf.release()
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?(FlutterError(
                    code: "NO_PERMISSION",
                    message: "Accessibility permission required for push-to-talk",
                    details: nil
                ))
            }
            return
        }

        eventTap = tap

        // Create run loop source and add to a background thread's run loop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        tapThread = Thread { [weak self] in
            guard let self = self, let source = self.runLoopSource else { return }
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            CFRunLoopRun()
        }
        tapThread?.name = "com.recognizing.ptt-event-tap"
        tapThread?.start()

        NSLog("[PTT] Event tap started, monitoring: \(monitoredKey)")
    }

    private func stopTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if runLoopSource != nil {
            // Stop the run loop on the tap thread
            if let thread = tapThread {
                perform(#selector(stopRunLoop), on: thread, with: nil, waitUntilDone: false)
            }
            runLoopSource = nil
        }

        if eventTap != nil {
            eventTap = nil
        }

        tapThread = nil
        NSLog("[PTT] Event tap stopped")
    }

    @objc private func stopRunLoop() {
        CFRunLoopStop(CFRunLoopGetCurrent())
    }

    private func handleFlagsChanged(_ event: CGEvent) {
        let flags = event.flags
        // The device-dependent flags are in the CGEvent's flags raw value
        let rawFlagBits = UInt64(flags.rawValue)

        let isTargetDown = isTargetKeyPressed(flags: flags, rawFlags: rawFlagBits)

        if isTargetDown && !isKeyDown {
            isKeyDown = true
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?("keyDown")
            }
        } else if !isTargetDown && isKeyDown {
            isKeyDown = false
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?("keyUp")
            }
        }
    }

    private func isTargetKeyPressed(flags: CGEventFlags, rawFlags: UInt64) -> Bool {
        // Extract device-dependent flags from the upper portion
        // The device flags are bits 16-31 of the raw flags value
        let deviceFlags = (rawFlags >> 16) & 0xFFFF

        switch monitoredKey {
        case "rightCommand":
            // Check if Command is held AND it's the right command key
            return flags.contains(.maskCommand) &&
                   (deviceFlags & PttEventTapService.NX_DEVICERCMDKEYMASK) != 0

        case "rightOption":
            // Check if Option is held AND it's the right option key
            return flags.contains(.maskAlternate) &&
                   (deviceFlags & PttEventTapService.NX_DEVICERALTKEYMASK) != 0

        case "fn":
            // Fn key uses the secondary function flag
            return flags.contains(.maskSecondaryFn)

        default:
            return false
        }
    }

    deinit {
        stopTap()
    }
}
