import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // Return false to keep the app running in the menu bar when the window is closed
    return false
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Set up window delegate to intercept close button
    if let window = NSApplication.shared.windows.first {
      window.delegate = self
      // Window remains visible on first launch for new users
      // When users close the window, it hides but stays in menu bar
    }
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    // Show the window when clicking the dock icon
    if !flag {
      for window in NSApplication.shared.windows {
        window.makeKeyAndOrderFront(self)
      }
    }
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

extension AppDelegate: NSWindowDelegate {
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    // Hide the window instead of closing it
    sender.orderOut(nil)
    return false
  }
}
