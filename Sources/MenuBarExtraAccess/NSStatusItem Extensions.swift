//
//  NSStatusItem Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import AppKit

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
    public func setPresentedMenuBased(state: Bool) {
        // read current state and selectively call toggle if state differs
        let currentState = button?.state != .off
        guard state != currentState else { return }
        togglePresented()
    }
    
    /// Toggles the menu/window state by mimicking a menu item button press.
    @_disfavoredOverload
    public func setPresentedWindowBased(state: Bool, window: NSWindow?) {
        // experiment #1:
        //   - try sending an action that might accomplish this?
        // invalid selectors: showWindow, hideWindow, closeWindow, close
        // button?.sendAction(Selector(("showWindow:")), to: button?.target)
        
        // experiment #2:
        // if we follow button.target, perhaps its state could help us
        // dump(button!.target) // SwiftUI.WindowMenuBarExtraBehavior <<< TELLS US IF IT'S MENU BASED
        
        // working solution #1:
        let isVisible = window?.isVisible == true
        guard state != isVisible else { return }
        togglePresented()
    }
}

extension NSWindow /* actually NSStatusBarWindow but it's a private AppKit type */ {
    /// When called on an `NSStatusBarWindow` instance, returns the associated `NSStatusItem`.
    /// Always returns `nil` for any other `NSWindow` subclass.
    @_disfavoredOverload
    public func fetchStatusItem() -> NSStatusItem? {
        // statusItem is a private key not exposed to Swift but we can get it using Key-Value coding
        value(forKey: "statusItem") as? NSStatusItem
        ?? Mirror(reflecting: self).descendant("statusItem") as? NSStatusItem
    }
}
