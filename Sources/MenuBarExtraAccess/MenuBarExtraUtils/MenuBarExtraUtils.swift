//
//  MenuBarExtraUtils.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit
import SwiftUI
import Combine

/// Global static utility methods for interacting the app's menu bar extras (status items).
@MainActor
enum MenuBarExtraUtils {
    // MARK: - Menu Extra Manipulation
    
    /// Toggle MenuBarExtra menu/window presentation state.
    static func togglePresented(for ident: StatusItemIdentity? = nil) {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("MenuBarExtraUtils.\(#function) called for status item \(ident?.description ?? "nil")")
        #endif
        
        guard let item = statusItem(for: ident) else { return }
        item.togglePresented()
    }
    
    /// Set MenuBarExtra menu/window presentation state.
    static func setPresented(for ident: StatusItemIdentity? = nil, state: Bool) {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("MenuBarExtraUtils.\(#function) called for status item \(ident?.description ?? "nil") with state \(state)")
        #endif
        
        guard let item = statusItem(for: ident) else { return }
        item.setPresented(state: state)
    }
    
    /// Set MenuBarExtra menu/window presentation state only when its state is reliably known.
    static func setKnownPresented(for ident: StatusItemIdentity? = nil, state: Bool) {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("MenuBarExtraUtils.\(#function) called for status item \(ident?.description ?? "nil") with state \(state)")
        #endif
        
        guard let item = statusItem(for: ident) else { return }
        item.setKnownPresented(state: state)
    }
    
    static func setEnabled(for ident: StatusItemIdentity? = nil, state: Bool) {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("MenuBarExtraUtils.\(#function) called for status item \(ident?.description ?? "nil") with state \(state)")
        #endif
        
        guard let item = statusItem(for: ident) else { return }
        item.setEnabled(state: state)
    }
}

// MARK: - Objects and Metadata

@MainActor
extension MenuBarExtraUtils {
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
                
                let statusItemClassName: String
                if #available(macOS 26.0, *) {
                    statusItemClassName = "NSSceneStatusItem"
                } else { // macOS 10.15.x through 15.x
                    statusItemClassName = "NSStatusItem"
                }
                
                guard let statusItem = window.fetchStatusItem(),
                      statusItem.className == statusItemClassName
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
                #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                print("MenuBarExtraUtils.\(#function): Window could not be found for status item with ID \"\(menuBarExtraID).")
                #endif
                
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

// MARK: - Observers

@MainActor
extension MenuBarExtraUtils {
    /// Call from MenuBarExtraAccess init to set up observer.
    static func newStatusItemButtonStateObserver(
        index: Int,
        _ handler: @MainActor @escaping @Sendable (_ change: NSKeyValueObservedChange<NSControl.StateValue>) -> Void
    ) -> NSStatusItem.ButtonStateObserver? {
        guard let statusItem = MenuBarExtraUtils.statusItem(for: .index(index)) else {
            #if MENUBAREXTRAACCESS_DEBUG_LOGGING
            print("Can't register menu bar extra state observer: Can't find status item. It may not yet exist.")
            #endif
            
            return nil
        }
        
        guard let observer = statusItem.stateObserverMenuBased(handler)
        else {
            #if MENUBAREXTRAACCESS_DEBUG_LOGGING
            print("Can't register menu bar extra state observer: Can't generate observer.")
            #endif
            
            return nil
        }
        
        return observer
    }
    
    /// Adds global event monitor to catch mouse events outside the application.
    static func newGlobalMouseDownEventsMonitor(
        _ handler: @escaping @Sendable (NSEvent) -> Void
    ) -> Any? {
        NSEvent.addGlobalMonitorForEvents(
            matching: [
                .leftMouseDown,
                .rightMouseDown,
                .otherMouseDown
            ],
            handler: handler
        )
    }
    
    /// Adds local event monitor to catch mouse events within the application.
    static func newLocalMouseDownEventsMonitor(
        _ handler: @escaping @Sendable (NSEvent) -> NSEvent?
    ) -> Any? {
        NSEvent.addLocalMonitorForEvents(
            matching: [
                .leftMouseDown,
                .rightMouseDown,
                .otherMouseDown
            ],
            handler: handler
        )
    }
    
    static func newStatusItemButtonStatePublisher(
        index: Int
    ) -> NSStatusItem.ButtonStatePublisher? {
        guard let statusItem = MenuBarExtraUtils.statusItem(for: .index(index)) else {
            #if MENUBAREXTRAACCESS_DEBUG_LOGGING
            print("Can't register menu bar extra state observer: Can't find status item. It may not yet exist.")
            #endif
            
            return nil
        }
        
        guard let publisher = statusItem.buttonStatePublisher()
        else {
            #if MENUBAREXTRAACCESS_DEBUG_LOGGING
            print("Can't register menu bar extra state observer: Can't generate publisher.")
            #endif
            
            return nil
        }
        
        return publisher
    }
    
    /// Wraps `newStatusItemButtonStatePublisher` in a sink.
    static func newStatusItemButtonStatePublisherSink(
        index: Int,
        block: @MainActor @escaping @Sendable (_ newValue: NSControl.StateValue?) -> Void
    ) -> AnyCancellable? {
        newStatusItemButtonStatePublisher(index: index)?
            .flatMap { value in
                Just(value)
                    .tryMap { value throws -> NSControl.StateValue in value }
                    .replaceError(with: nil)
            }
            .sink(receiveValue: { value in
                block(value)
            })
    }
    
    static func newWindowObserver(
        index: Int,
        for notification: Notification.Name,
        block: @MainActor @escaping @Sendable (_ window: NSWindow) -> Void
    ) -> AnyCancellable? {
        NotificationCenter.default.publisher(for: notification)
            .filter { output in
                guard let window = output.object as? NSWindow else { return false }
                guard let windowWithIndex = MenuBarExtraUtils.window(for: .index(index)) else { return false }
                return window == windowWithIndex
            }
            .sink { output in
                guard let window = output.object as? NSWindow else { return }
                block(window)
            }
    }
}

// MARK: - NSStatusItem Introspection

@MainActor
extension NSStatusItem {
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
            #if MENUBAREXTRAACCESS_DEBUG_LOGGING
            print("Could not find status item's target.")
            #endif
            
            return nil
        }

        return mirror.menuBarExtraID()
    }
    
    var isMenuBarExtraMenuBased: Bool {
        // if window-based, target will be the internal type SwiftUI.WindowMenuBarExtraBehavior
        // if menu-based, target will be nil
        guard let behavior = button?.target
        else {
            return true
        }
        
        // the rest of this is probably redundant given the check above covers both scenarios.
        // however, WindowMenuBarExtraBehavior does contain an explicit `isMenuBased` Bool we can read
        guard let mirror = Mirror(reflecting: behavior).superclassMirror
        else {
            #if MENUBAREXTRAACCESS_DEBUG_LOGGING
            print("Could not find status item's target.")
            #endif
            
            return false
        }
        
        return mirror.isMenuBarExtraMenuBased()
    }
}

// MARK: - NSWindow Introspection

@MainActor
extension NSWindow {
    fileprivate var menuBarExtraID: String? {
        // Note: this is not ideal, but it's currently the ONLY way to achieve this
        // until Apple adds a 1st-party solution to MenuBarExtra state
        
        let mirror = Mirror(reflecting: self)
        return mirror.menuBarExtraID()
    }
}

@MainActor
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
        
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("Could not determine MenuBarExtra ID")
        #endif
        
        return nil
    }
    
    fileprivate func isMenuBarExtraMenuBased() -> Bool {
        descendant(
            "configuration",
            "isMenuBased"
        ) as? Bool ?? false
    }
}

// MARK: - Misc.

@MainActor
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

#endif
