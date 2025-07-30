//
//  NSStatusItem Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
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
    internal func setPresented(state: Bool) {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function) called with state: \(state)")
        #endif
        
        // read current state and selectively call toggle if state differs
        let currentState = button?.state != .off
        guard state != currentState else {
            updateHighlight()
            return
        }
        
        // don't allow presenting the menu if the status item is disabled
        if state { guard button?.isEnabled == true else { return } }
        
        togglePresented()
    }
    
    @_disfavoredOverload
    internal func updateHighlight() {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function) called")
        #endif
        
        let s = button?.state != .off
        
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function): State detected as \(s)")
        #endif
        
        button?.isHighlighted = s
    }
    
    /// Only call this when the state of the drop-down window is known.
    internal func setKnownPresented(state: Bool) {
        switch state {
        case true:
            button?.state = .on
        case false:
            button?.state = .off
        }
    }
    
    internal func setEnabled(state: Bool) {
        button?.isEnabled = state
    }
}

// MARK: - KVO Observer

@MainActor
extension NSStatusItem {
    @MainActor
    internal class ButtonStateObserver: NSObject {
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
    
    internal func stateObserverMenuBased(
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
    
    internal func buttonStatePublisher() -> ButtonStatePublisher? {
        button?.publisher(for: \.cell!.state, options: [.initial, .new])
    }
}

#endif
