//
//  MenuBarExtraUtils.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import AppKit
import SwiftUI

/// Global static utility methods for interacting the app's menu bar extras (status items).
enum MenuBarExtraUtils {
    /// Toggle MenuBarExtra menu/window presentation state.
    static func togglePresented(for ident: StatusItemIdentity? = nil) {
        statusItem(for: ident)?.togglePresented()
    }
    
    /// Set MenuBarExtra menu/window presentation state.
    static func setPresented(for ident: StatusItemIdentity? = nil, state: Bool) {
        guard let item = statusItem(for: ident) else { return }
        
        if item.isMenuBarExtraMenuBased {
            item.setPresentedMenuBased(state: state)
        } else {
            let window = window(for: ident)
            item.setPresentedWindowBased(state: state, window: window)
        }
    }
    
    /// Returns the underlying status item(s) created by `MenuBarExtra` instances.
    ///
    /// Each `MenuBarExtra` creates one status item.
    ///
    /// If the `isInserted` binding on a `MenuBarExtra` is set to false, it may not return a status
    /// item. This may also change its index.
    static var statusItems: [NSStatusItem] {
        NSApp.windows
            .filter {
                $0.className.contains("NSStatusBarWindow")
            }
            .compactMap { window -> NSStatusItem? in
                // On Macs with only one display, there should only be one result.
                // On Macs with two or more displays and system prefs set to "Displays have Separate
                // Spaces", one NSStatusBarWindow instance per display will be returned.
                // - the main/active instance has a statusItem property of type NSStatusItem
                // - the other(s) have a statusItem property of type NSStatusItemReplicant
                
                // NSStatusItemReplicant is a replica for displaying the status item on inactive
                // spaces/screens that happens to be an NSStatusItem subclass.
                // both respond to the action selector being sent to them.
                // We only need to interact with the main non-replica status item.
                guard let statusItem = window.fetchStatusItem(),
                      statusItem.className == "NSStatusItem"
                else { return nil }
                return statusItem
            }
    }
    
    /// Returns the underlying status items created by `MenuBarExtra` for the
    /// `MenuBarExtra` with the specified index.
    ///
    /// Each `MenuBarExtra` creates one status item.
    ///
    /// If the `isInserted` binding on a `MenuBarExtra` is set to false, it may not return a status
    /// item. This may also change its index.
    static func statusItem(for ident: StatusItemIdentity? = nil) -> NSStatusItem? {
        let statusItems = statusItems
        
        guard let ident else { return statusItems.first }
        
        switch ident {
        case .id(let menuBarExtraID):
            return statusItems.filter { $0.menuBarExtraID == menuBarExtraID }.first
        case .index(let index):
            guard statusItems.indices.contains(index) else { return nil }
            return statusItems[index]
        }
    }
    
    /// Returns window associated with a window-based MenuBarExtra.
    /// Always returns `nil` for a menu-based MenuBarExtra.
    static func window(for ident: StatusItemIdentity? = nil) -> NSWindow? {
        // we can't use NSStatusItem.window because it won't work
        
        let menuBarWindows = NSApp.windows.filter {
            $0.className.contains("MenuBarExtraWindow")
        }
        
        guard let ident else { return menuBarWindows.first }
        
        switch ident {
        case .id(let menuBarExtraID):
            guard let match = menuBarWindows.first(where: { $0.menuBarExtraID == menuBarExtraID }) else {
                print("Window could not be found for status item with ID \"\(menuBarExtraID).")
                return nil
            }
            return match
        case .index(_):
            guard let item = statusItem(for: ident) else { return nil }
            
            return menuBarWindows.first { window in
                guard let statusItem = window.fetchStatusItem() else { return false }
                return item == statusItem
            }
        }
    }
}

enum StatusItemIdentity {
    case index(Int)
    case id(String)
}

extension NSStatusItem {
    // may not be needed
    var menuBarExtraIndex: Int {
        MenuBarExtraUtils.statusItems.firstIndex(of: self) ?? 0
    }
    
    /// Returns the ID string for the status item.
    /// Returns `nil` if the status item does not contain a `MacControlCenterMenu`
    fileprivate var menuBarExtraID: String? {
        // Note: this is not ideal, but it's currently the ONLY way to achieve this
        // until Apple adds a 1st-party solution to MenuBarExtra state
        
        // dump(statusItem.button!.target):
        // ▿ some: SwiftUI.WindowMenuBarExtraBehavior #0
        //   ▿ super: SwiftUI.MenuBarExtraBehavior
        //     - statusItem: <NSStatusItem: 0x600000c6cdc0> #1
        //   ▿ configuration: SwiftUI.MenuBarExtraConfiguration
        //     ▿ label: SwiftUI.AnyView ---> contains the status item label, icon
        //     ▿ mainContent: SwiftUI.AnyView ---> contains the view content
        //       - storage
        //         - view
        //           - ... ---> properties of the view will be itemized here
        //     - shouldQuitWhenRemoved: true
        //     ▿ _isInserted: SwiftUI.Binding<Swift.Bool> ---> isInserted binding backing
        //     - isMenuBased: false
        //     - implicitID: "YourApp.Menu"
        //     - resizability: SwiftUI.WindowResizability.Role.automatic
        //     - defaultSize: nil
        //   ▿ environment: [] ---> SwiftUI environment vars/locale/openWindow method
        
        // this may require a less brittle solution if the child path may change, such as grabbing
        // String(dump: behavior) and using RegEx to find the value
        
        guard let behavior = button?.target, // SwiftUI.WindowMenuBarExtraBehavior <- internal
              let mirror = Mirror(reflecting: behavior).superclassMirror
        else {
            print("Could not find status item's target.")
            return nil
        }

        return mirror.menuBarExtraID()
    }
    
    fileprivate var isMenuBarExtraMenuBased: Bool {
        // if window-based, target will be the internal type SwiftUI.WindowMenuBarExtraBehavior
        // if menu-based, target will be nil
        guard let behavior = button?.target
        else {
            return false
        }
        
        // the rest of this is probably redundant given the check above covers both scenarios.
        // however, WindowMenuBarExtraBehavior does contain an explicit `isMenuBased` Bool we can read
        guard let mirror = Mirror(reflecting: behavior).superclassMirror
        else {
            print("Could not find status item's target.")
            return false
        }
        
        return mirror.isMenuBarExtraMenuBased()
    }
}

extension NSWindow {
    fileprivate var menuBarExtraID: String? {
        // Note: this is not ideal, but it's currently the ONLY way to achieve this
        // until Apple adds a 1st-party solution to MenuBarExtra state
        
        let mirror = Mirror(reflecting: self)
        return mirror.menuBarExtraID()
    }
}

extension Mirror {
    fileprivate func menuBarExtraID() -> String? {
        // Note: this is not ideal, but it's currently the ONLY way to achieve this
        // until Apple adds a 1st-party solution to MenuBarExtra state
        
        // this may require a less brittle solution if the child path may change, such as grabbing
        // String(dump: behavior) and using RegEx to find the value
        
        // when using MenuBarExtra(title string, content) this is the mirror path:
        if let id = descendant(
            "configuration",
            "label",
            "storage",
            "view",
            "content",
            "title",
            "storage",
            "anyTextStorage",
            "key",
            "key"
        ) as? String {
            return id
        }
        
        // this won't work. it differs when checked from MenuBarExtraAccess / menuBarExtraAccess(isPresented:)
        // internals. MenuBarExtra wraps the label in additional modifiers/AnyView here.
        //
        // otherwise, when using a MenuBarExtra initializer that produces Label view content:
        // we'll basically grab the hashed contents of the label
        if let anyView = descendant(
            "configuration",
            "label"
        ) as? any View {
            let hashed = MenuBarExtraUtils.hash(anyView: anyView)
            print("hash:", hashed)
            return hashed
        }
        
        print("Could not determine MenuBarExtra ID")
        
        return nil
    }
    
    fileprivate func isMenuBarExtraMenuBased() -> Bool {
        descendant(
            "configuration",
            "isMenuBased"
        ) as? Bool ?? false
    }
}

extension MenuBarExtraUtils {
    static func hash(anyView: any View) -> String {
        // can't hash `any View`
        //
        // var h = Hasher()
        // let ah = AnyHashable(anyView)
        // h.combine(anyView)
        // let i = h.finalize()
        // return String(i)
        
        // return "\(anyView)"
        return String("\(anyView)".hashValue)
    }
}
