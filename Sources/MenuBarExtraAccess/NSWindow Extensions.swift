//
//  NSWindow Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import AppKit

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
