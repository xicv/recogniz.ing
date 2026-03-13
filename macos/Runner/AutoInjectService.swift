import Cocoa

/// Service for detecting focused text inputs and injecting text via simulated Cmd+V.
///
/// Uses macOS Accessibility API (AXUIElement) to check if the currently focused
/// UI element is a text input field, and CGEvent to simulate keystrokes.
/// Requires Accessibility permission.
class AutoInjectService {

    /// Check if the currently focused UI element is a text input.
    ///
    /// Queries the system-wide accessibility element for the focused element,
    /// then checks its AX role against known text input roles.
    static func isFocusedElementTextInput() -> Bool {
        let systemWide = AXUIElementCreateSystemWide()

        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )

        guard result == .success, let element = focusedElement else {
            return false
        }

        var role: AnyObject?
        AXUIElementCopyAttributeValue(
            element as! AXUIElement,
            kAXRoleAttribute as CFString,
            &role
        )

        let roleStr = role as? String ?? ""
        let textRoles = [
            "AXTextField",
            "AXTextArea",
            "AXComboBox",
            "AXSearchField",
            "AXWebArea",  // Web-based text inputs (browsers, Electron apps)
        ]
        return textRoles.contains(roleStr)
    }

    /// Inject text by setting clipboard and simulating Cmd+V, then restoring clipboard.
    ///
    /// Steps:
    /// 1. Save current clipboard contents
    /// 2. Set clipboard to the target text
    /// 3. Simulate Cmd+V keystroke
    /// 4. After a short delay, restore the original clipboard
    static func injectText(_ text: String) {
        let pasteboard = NSPasteboard.general

        // 1. Save current clipboard
        let previousContents = pasteboard.string(forType: .string)
        let previousChangeCount = pasteboard.changeCount

        // 2. Set clipboard to our text
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // 3. Simulate Cmd+V
        simulateCmdV()

        // 4. Restore clipboard after a delay (150ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Only restore if clipboard hasn't been changed by something else
            if pasteboard.changeCount == previousChangeCount + 1 {
                pasteboard.clearContents()
                if let previous = previousContents {
                    pasteboard.setString(previous, forType: .string)
                }
            }
        }
    }

    /// Simulate Cmd+V keystroke using CGEvent.
    private static func simulateCmdV() {
        let source = CGEventSource(stateID: .hidSystemState)

        // 'v' key = keycode 9
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)

        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
