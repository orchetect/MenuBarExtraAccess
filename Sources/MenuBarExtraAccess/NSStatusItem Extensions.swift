//
//  NSStatusItem Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit
import SwiftUI

@MainActor
extension NSStatusItem {
    /// Toggles the menu/window state by mimicking a menu item button press.
    @_disfavoredOverload
    public func togglePresented() {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function) called")
        #endif

        // on macOS 27+, window-based MenuBarExtra presentation is driven by AppKit's
        // expanded interface session machinery and the button's target/action are nil,
        // so a simulated button click no longer presents the window.
        // see `NSStatusItem+ExpandedInterfaceSession.swift` for details.
        if usesExpandedInterfaceSession {
            if expandedInterfaceSession != nil {
                cancelExpandedInterfaceSession()
            } else {
                beginExpandedInterfaceSession()
            }
            return
        }

        // this also works but only for window-based MenuBarExtra
        // (button.target and button.action are nil when menu-based):
        //   - mimic user pressing the menu item button
        //     which convinces MenuBarExtra to close the window and properly reset its state
        // let actionSelector = button?.action // "toggleWindow:" selector
        // button?.sendAction(actionSelector, to: button?.target)

        button?.performClick(button)
        updateHighlight()
    }

    /// Toggles the menu/window state by mimicking a menu item button press.
    @_disfavoredOverload
    func setPresented(state: Bool) {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function) called with state: \(state)")
        #endif

        // read current state and selectively call toggle if state differs
        guard state != isMenuBarExtraPresented else {
            updateHighlight()
            return
        }

        // don't allow presenting the menu if the status item is disabled
        if state {
            guard button?.isEnabled == true else { return }
        }

        togglePresented()
    }

    /// Current presentation state, regardless of macOS version or presentation mechanism.
    var isMenuBarExtraPresented: Bool {
        if usesExpandedInterfaceSession {
            // on macOS 27+ the session is the source of truth; the button state remains `.off`
            return expandedInterfaceSession != nil
        }
        return button?.state != .off
    }

    @_disfavoredOverload
    func updateHighlight() {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function) called")
        #endif

        // the system manages the button highlight for session-based presentation
        guard !usesExpandedInterfaceSession else { return }

        let s = button?.state != .off

        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function): State detected as \(s)")
        #endif

        button?.isHighlighted = s
    }

    /// Only call this when the state of the drop-down window is known.
    func setKnownPresented(state: Bool) {
        // on macOS 27+ the button state does not participate in presentation;
        // leave it `.off` so that fallback state reads remain consistent
        guard !usesExpandedInterfaceSession else { return }

        switch state {
        case true:
            button?.state = .on
        case false:
            button?.state = .off
        }
    }

    func setEnabled(state: Bool) {
        button?.isEnabled = state

        // on macOS 27+ the button's enabled state never reaches the system menu bar host,
        // which begins an expanded interface session on click regardless. detaching the
        // status item's delegate is what actually disables click-to-present.
        if state {
            restoreExpandedInterfaceDelegate()
        } else {
            suspendExpandedInterfaceDelegate()
        }
    }
}

// MARK: - KVO Observer

@MainActor
extension NSStatusItem {
    @MainActor
    class ButtonStateObserver: NSObject {
        private weak var objectToObserve: NSStatusBarButton?
        private var observation: NSKeyValueObservation?

        init(
            object: NSStatusBarButton,
            _ handler: @MainActor @escaping @Sendable (_ change: NSKeyValueObservedChange<NSControl.StateValue>) -> Void
        ) {
            objectToObserve = object
            super.init()

            observation = object.observe(
                \.cell!.state,
                options: [.initial, .new]
            ) { ob, change in
                Task { @MainActor in handler(change) }
            }
        }

        deinit {
            observation?.invalidate()
        }
    }

    func stateObserverMenuBased(
        _ handler: @MainActor @escaping @Sendable (_ change: NSKeyValueObservedChange<NSControl.StateValue>) -> Void
    ) -> ButtonStateObserver? {
        guard let button else { return nil }
        let newStatusItemButtonStateObserver = ButtonStateObserver(object: button, handler)
        return newStatusItemButtonStateObserver
    }
}

// MARK: - KVO Publisher

@MainActor
extension NSStatusItem {
    typealias ButtonStatePublisher = KeyValueObservingPublisher<NSStatusBarButton, NSControl.StateValue>

    func buttonStatePublisher() -> ButtonStatePublisher? {
        button?.publisher(for: \.cell!.state, options: [.initial, .new])
    }
}

#endif
