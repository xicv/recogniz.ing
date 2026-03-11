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
        result(AXIsProcessTrusted())
      case "openSettings":
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
          NSWorkspace.shared.open(url)
        }
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
