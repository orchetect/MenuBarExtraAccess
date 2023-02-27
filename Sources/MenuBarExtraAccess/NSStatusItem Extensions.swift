//
//  NSStatusItem Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import AppKit
import SwiftUI

extension NSStatusItem {
    /// Toggles the menu/window state by mimicking a menu item button press.
    @_disfavoredOverload
    public func togglePresented() {
        // this also works but only for window-based MenuBarExtra
        // (button.target and button.action are nil when menu-based):
        //   - mimic user pressing the menu item button
        //     which convinces MenuBarExtra to close the window and properly reset its state
        // let actionSelector = button?.action // "toggleWindow:" selector
        // button?.sendAction(actionSelector, to: button?.target)
        
        button?.performClick(button)
    }
    
    /// Toggles the menu/window state by mimicking a menu item button press.
    @_disfavoredOverload
    internal func setPresented(state: Bool) {
        // read current state and selectively call toggle if state differs
        let currentState = button?.state != .off
        guard state != currentState else { return }
        togglePresented()
    }
}

// MARK: - KVO Observer

extension NSStatusItem {
    internal class ButtonStateObserver: NSObject {
        private weak var objectToObserve: NSStatusBarButton?
        private var observation: NSKeyValueObservation?
        
        init(
            object: NSStatusBarButton,
            _ handler: @escaping (_ change: NSKeyValueObservedChange<NSControl.StateValue>)
                -> Void
        ) {
            objectToObserve = object
            super.init()
            
            observation = object.observe(
                \.cell!.state,
                 options: [.initial, .new]
            ) { ob, change in
                handler(change)
            }
        }
        
        deinit {
            //print("Observer deinit")
            observation?.invalidate()
        }
    }
    
    internal func stateObserverMenuBased(
        _ handler: @escaping (_ change: NSKeyValueObservedChange<NSControl.StateValue>) -> Void
    ) -> ButtonStateObserver? {
        guard let button else { return nil }
        let newObserver = ButtonStateObserver(object: button, handler)
        return newObserver
    }
}

// MARK: - KVO Publisher

extension NSStatusItem {
    typealias ButtonStatePublisher = KeyValueObservingPublisher<NSStatusBarButton, NSControl.StateValue>
    
    internal func buttonStatePublisher() -> ButtonStatePublisher? {
        button?.publisher(for: \.cell!.state, options: [.initial, .new])
    }
}
