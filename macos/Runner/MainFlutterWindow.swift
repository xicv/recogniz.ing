import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Set up method channel for window control
    let channel = FlutterMethodChannel(
      name: "com.recognizing.app/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "showWindow":
        self?.showWindow()
        result(nil)
      case "hideWindow":
        self?.hideWindow()
        result(nil)
      case "isVisible":
        result(self?.isVisible ?? false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Set up method channel for accessibility permission
    let accessibilityChannel = FlutterMethodChannel(
      name: "com.recognizing.app/accessibility",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    accessibilityChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "checkPermission":
        // Use AXIsProcessTrustedWithOptions for a fresh check (bypasses some caching)
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): false] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        result(trusted)
      case "openSettings":
        // Try modern System Settings URL first (macOS 13+), fall back to legacy
        let modernURL = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility")
        let legacyURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        if let url = modernURL ?? legacyURL {
          NSWorkspace.shared.open(url)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Set up PTT EventChannel for streaming key events
    let pttService = PttEventTapService()
    let pttChannel = FlutterEventChannel(
      name: "com.recognizing.app/ptt",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    pttChannel.setStreamHandler(pttService)

    // PTT configuration MethodChannel
    let pttMethodChannel = FlutterMethodChannel(
      name: "com.recognizing.app/ptt_config",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    pttMethodChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "setKey":
        let key = call.arguments as? String ?? "rightCommand"
        pttService.setMonitoredKey(key)
        result(nil)
      case "startMonitoring":
        pttService.startMonitoring()
        result(nil)
      case "stopMonitoring":
        pttService.stopMonitoring()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Auto-inject MethodChannel
    let autoInjectChannel = FlutterMethodChannel(
      name: "com.recognizing.app/autoinject",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    autoInjectChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "isTextInputFocused":
        result(AutoInjectService.isFocusedElementTextInput())
      case "injectText":
        let text = call.arguments as? String ?? ""
        AutoInjectService.injectText(text)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  private func showWindow() {
    NSApplication.shared.activate(ignoringOtherApps: true)
    self.makeKeyAndOrderFront(nil)
  }

  private func hideWindow() {
    self.orderOut(nil)
  }
}
