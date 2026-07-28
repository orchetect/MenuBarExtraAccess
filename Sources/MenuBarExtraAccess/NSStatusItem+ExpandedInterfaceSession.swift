//
//  NSStatusItem+ExpandedInterfaceSession.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(AppKit)

import AppKit

// MARK: - Expanded Interface Session (macOS 27+)

// Starting with macOS 27, SwiftUI no longer wires a window-based MenuBarExtra to its status item
// button's target/action (both are now nil), so simulating a button click no longer toggles the
// window. Presentation is instead driven by private AppKit "expanded interface session" machinery:
//
// 1. A click on the status item is delivered from the system menu bar as a scene action.
// 2. AppKit begins an `NSStatusItemExpandedInterfaceSession` and notifies the status item's
//    `expandedInterfaceDelegate`, which SwiftUI sets to its internal `WindowMenuBarExtraBehavior`
//    (the same object that was the button's `target` on macOS 26 and earlier).
// 3. The delegate shows or hides the MenuBarExtra window in response to the session
//    beginning/ending.
//
// `NSStatusItem.expandedInterfaceSession` is non-nil while the window is presented. The button's
// `state` remains `.off` throughout and can no longer be used to detect or drive presentation.
//
// All symbols involved are SPI, so everything below is invoked dynamically and guarded by runtime
// `responds(to:)` checks. On macOS 26 and earlier — and for menu-based MenuBarExtras, which have
// no delegate — these members are inert and callers fall back to the legacy button target/action
// mechanism.

@MainActor
extension NSStatusItem {
    private enum SPI {
        static let beginSession = NSSelectorFromString("_beginExpandedInterfaceSession:")
        static let session = NSSelectorFromString("expandedInterfaceSession")
        static let delegate = NSSelectorFromString("expandedInterfaceDelegate")
        static let setDelegate = NSSelectorFromString("setExpandedInterfaceDelegate:")
        static let cancel = NSSelectorFromString("cancel")
    }

    /// Returns `true` if this status item presents its content using the expanded interface
    /// session mechanism (a window-based `MenuBarExtra` on macOS 27 or later).
    var usesExpandedInterfaceSession: Bool {
        responds(to: SPI.beginSession) && expandedInterfaceDelegate != nil
    }

    /// The status item's `expandedInterfaceDelegate` (macOS 27+): SwiftUI's internal
    /// `WindowMenuBarExtraBehavior` for a window-based `MenuBarExtra`, otherwise `nil`.
    var expandedInterfaceDelegate: AnyObject? {
        guard responds(to: SPI.delegate) else { return nil }
        return perform(SPI.delegate)?.takeUnretainedValue()
    }

    /// The active `NSStatusItemExpandedInterfaceSession`, or `nil` while not presented
    /// (macOS 27+).
    var expandedInterfaceSession: NSObject? {
        guard responds(to: SPI.session) else { return nil }
        return perform(SPI.session)?.takeUnretainedValue() as? NSObject
    }

    /// Begins an expanded interface session, presenting the MenuBarExtra window via the status
    /// item's delegate (macOS 27+).
    ///
    /// `-[NSStatusItem _beginExpandedInterfaceSession:]` takes the timestamp of the event that
    /// triggered the session and silently drops any begin whose timestamp predates the end of
    /// the previous session — a debounce so the click that dismisses the window cannot
    /// immediately re-present it. Programmatic presentation has no triggering event, so pass
    /// the maximum timestamp to always pass that check.
    /// (`-[NSStatusItem _requestExpandedInterfaceSession]`, the round-trip variant that asks
    /// the system menu bar host to begin the session, falls afoul of the same debounce and is
    /// unreliable for repeated presentation.)
    func beginExpandedInterfaceSession() {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function) called")
        #endif

        guard expandedInterfaceSession == nil,
              responds(to: SPI.beginSession),
              let implementation = method(for: SPI.beginSession)
        else { return }

        typealias BeginSession = @convention(c) (NSStatusItem, Selector, TimeInterval) -> Void
        unsafeBitCast(implementation, to: BeginSession.self)(self, SPI.beginSession, .greatestFiniteMagnitude)
    }

    /// Cancels the active expanded interface session, dismissing the MenuBarExtra window
    /// (macOS 27+). This mirrors how SwiftUI itself dismisses the window.
    func cancelExpandedInterfaceSession() {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("NSStatusItem.\(#function) called")
        #endif

        guard let session = expandedInterfaceSession,
              session.responds(to: SPI.cancel)
        else { return }

        session.perform(SPI.cancel)
    }
}

// MARK: - Suspending Presentation While Disabled

// On macOS 27+ the button's `isEnabled` state never reaches the system menu bar host, so a click
// on a "disabled" status item still begins a session and momentarily flashes the window before
// any in-process code can react. Removing the status item's delegate is what actually prevents
// this: it clears the scene's supports-expanded-interface setting so a click never begins a
// session in the first place. The delegate is stashed weakly so it can be reinstated when the
// item is re-enabled.

@MainActor
extension NSStatusItem {
    private static let suspendedDelegateKey: UnsafeMutableRawPointer = malloc(1)!

    private final class WeakRef {
        private(set) weak var object: AnyObject?
        init(_ object: AnyObject) {
            self.object = object
        }
    }

    /// The delegate stashed by ``suspendExpandedInterfaceDelegate()``, if presentation is
    /// currently suspended (macOS 27+).
    var suspendedExpandedInterfaceDelegate: AnyObject? {
        (objc_getAssociatedObject(self, Self.suspendedDelegateKey) as? WeakRef)?.object
    }

    /// Detaches the status item's expanded interface delegate so that clicking the item no
    /// longer begins a session, stashing it for later restoration (macOS 27+).
    /// Harmless no-op if unsupported by the OS or already suspended.
    func suspendExpandedInterfaceDelegate() {
        guard responds(to: SPI.setDelegate),
              let delegate = expandedInterfaceDelegate
        else { return }

        objc_setAssociatedObject(self, Self.suspendedDelegateKey, WeakRef(delegate), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        perform(SPI.setDelegate, with: nil)
    }

    /// Reinstates a delegate previously detached by ``suspendExpandedInterfaceDelegate()``
    /// (macOS 27+). Harmless no-op if unsupported by the OS or nothing is suspended.
    func restoreExpandedInterfaceDelegate() {
        guard responds(to: SPI.setDelegate),
              let ref = objc_getAssociatedObject(self, Self.suspendedDelegateKey) as? WeakRef
        else { return }

        objc_setAssociatedObject(self, Self.suspendedDelegateKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // don't clobber a delegate SwiftUI may have re-set in the interim
        guard expandedInterfaceDelegate == nil, let delegate = ref.object else { return }
        perform(SPI.setDelegate, with: delegate)
    }
}

#endif
