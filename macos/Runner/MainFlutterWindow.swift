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
