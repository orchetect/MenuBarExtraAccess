//
//  MenuBarExtraAccess.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import SwiftUI
import Combine

@available(macOS 13.0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@MainActor // required for Xcode 15 builds
extension Scene {
    /// Adds a presentation state binding to `MenuBarExtra`.
    /// If more than one MenuBarExtra are used in the app, provide the sequential index number of the `MenuBarExtra`.
    public func menuBarExtraAccess(
        index: Int = 0,
        isPresented: Binding<Bool>,
        isEnabled: Binding<Bool> = .constant(true),
        statusItem: ((_ statusItem: NSStatusItem) -> Void)? = nil
    ) -> some Scene {
        // FYI: SwiftUI will reinitialize the MenuBarExtra (and this view modifier)
        // if its title/label content changes, which means the stored ID will always be up-to-date
        
        MenuBarExtraAccess(
            index: index,
            statusItemIntrospection: statusItem,
            menuBarExtra: self,
            isMenuPresented: isPresented,
            isStatusItemEnabled: isEnabled
        )
    }
}

@available(macOS 13.0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@MainActor // required for Xcode 15 builds
struct MenuBarExtraAccess<Content: Scene>: Scene {
    let index: Int
    let statusItemIntrospection: ((_ statusItem: NSStatusItem) -> Void)?
    let menuBarExtra: Content
    @Binding var isMenuPresented: Bool
    @Binding var isStatusItemEnabled: Bool
    
    init(
        index: Int,
        statusItemIntrospection: ((_ statusItem: NSStatusItem) -> Void)?,
        menuBarExtra: Content,
        isMenuPresented: Binding<Bool>,
        isStatusItemEnabled: Binding<Bool>
    ) {
        self.index = index
        self.statusItemIntrospection = statusItemIntrospection
        self.menuBarExtra = menuBarExtra
        self._isMenuPresented = isMenuPresented
        self._isStatusItemEnabled = isStatusItemEnabled
    }
    
    var body: some Scene {
        menuBarExtra
            .onChange(of: observerSetup()) { newValue in
                // do nothing here - the method runs setup when polled by SwiftUI
            }
            .onChange(of: isMenuPresented) { newValue in
                setPresented(newValue)
            }
            .onChange(of: isStatusItemEnabled) { newValue in
                setStatusItemEnabled(newValue)
            }
    }
    
    private func togglePresented() {
        MenuBarExtraUtils.togglePresented(for: .index(index))
    }
    
    private func setPresented(_ state: Bool) {
        var state = state
        if state, !isStatusItemEnabled {
            // prevent presenting menu/window if item is disabled
            state = false
        }
        MenuBarExtraUtils.setPresented(for: .index(index), state: state)
    }
    
    private func setStatusItemEnabled(_ state: Bool) {
        if !state, isMenuPresented {
            // close menu if it's open
            isMenuPresented = false
            MenuBarExtraUtils.setPresented(for: .index(index), state: false)
        }
        
        MenuBarExtraUtils.setEnabled(for: .index(index), state: state)
    }
    
    // MARK: Observer
    
    /// A workaround since `onAppear {}` is not available in a SwiftUI Scene.
    /// We need to set up the observer, but it can't be set up in the scene init because it needs to
    /// update scene state from an escaping closure.
    /// This returns a bogus value, but because we call it in an `onChange {}` block, SwiftUI
    /// is forced to evaluate the method and run our code at the appropriate time.
    private func observerSetup() -> Int {
        #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        print("menuBarExtraAccess observerSetup() called")
        #endif
        
        observerContainer.setupStatusItemIntrospection {
            // attempt to get status item for a short period of time before giving up
            let timeout: TimeInterval = 2.0
            let pollingInterval: TimeInterval = 0.2
            let inTime = Date()
            while !Task.isCancelled,
                  Date().timeIntervalSince(inTime) < timeout
            {
                guard let statusItem = MenuBarExtraUtils.statusItem(for: .index(index)) else {
                    try? await Task.sleep(for: .seconds(pollingInterval))
                    continue
                }
                
                statusItemIntrospection?(statusItem)
                
                // initial setup
                setStatusItemEnabled(isStatusItemEnabled)
                
                return true
            }
            
            // timed out
            return false
        }
        
        // note that we can't use the button state value itself since MenuBarExtra seems to treat it
        // as a toggle and not an absolute on/off value. Its polarity can invert itself when clicking
        // in an empty area of the menubar or a different app's status item in order to dismiss the window,
        // for example.
        observerContainer.setupStatusItemButtonStateObserver {
            MenuBarExtraUtils.newStatusItemButtonStateObserver(index: index) { change in
                #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                print("Status item button state observer: called with change: \(change.newValue?.name ?? "nil")")
                #endif
                
                // only continue if the MenuBarExtra is menu-based.
                // window-based MenuBarExtras are handled with app-bound window observers instead.
                guard MenuBarExtraUtils.statusItem(for: .index(index))?
                    .isMenuBarExtraMenuBased == true
                else { return }
                
                guard let newVal = change.newValue else { return }
                let newBool = newVal != .off
                if isMenuPresented != newBool {
                    #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                    print("Status item button state observer: Setting isMenuPresented to \(newBool)")
                    #endif
                    
                    isMenuPresented = newBool
                }
            }
        }
        
        // TODO: this mouse event observer is now redundant and can be deleted in the future
        
        // observerContainer.setupGlobalMouseDownMonitor {
        //     // note that this won't fire when mouse events within the app cause the window to dismiss
        //     MenuBarExtraUtils.newGlobalMouseDownEventsMonitor { event in
        //         #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        //         print("Global mouse-down events monitor: called with event: \(event.type.name)")
        //         #endif
        //
        //         // close window when user clicks outside of it
        //
        //         MenuBarExtraUtils.setPresented(for: .index(index), state: false)
        //
        //         #if MENUBAREXTRAACCESS_DEBUG_LOGGING
        //         print("Global mouse-down events monitor: Setting isMenuPresented to false")
        //         #endif
        //
        //         isMenuPresented = false
        //     }
        // }
        
        observerContainer.setupWindowObservers(
            index: index,
            didBecomeKey: { window in
                #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                print("MenuBarExtra index \(index) drop-down window did become key.")
                #endif
                
                MenuBarExtraUtils.setKnownPresented(for: .index(index), state: true)
                isMenuPresented = true
            },
            didResignKey: { window in
                #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                print("MenuBarExtra index \(index) drop-down window did resign as key.")
                #endif
                
                // it's possible for a window to resign key without actually closing, so let's
                // close it as a failsafe.
                if window.isVisible {
                    #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                    print("Closing MenuBarExtra index \(index) drop-down window as a result of it resigning as key.")
                    #endif
                    
                    window.close()
                }
                
                MenuBarExtraUtils.setKnownPresented(for: .index(index), state: false)
                isMenuPresented = false
            }
        )
        
        return 0
    }
    
    // MARK: Observers
    
    private var observerContainer = ObserverContainer()
    
    @MainActor
    private class ObserverContainer {
        private var statusItemIntrospectionSetupPhase: SetupPhase = .notStarted
        private var observer: NSStatusItem.ButtonStateObserver?
        private var eventsMonitor: Any?
        private var windowDidBecomeKeyObserver: AnyCancellable?
        private var windowDidResignKeyObserver: AnyCancellable?
        
        init() { }
        
        enum SetupPhase: Equatable, Hashable, Sendable {
            case notStarted
            case started
            case failed
            case succeeded
        }
        
        func setupStatusItemIntrospection(
            _ block: @MainActor @escaping @Sendable () async -> Bool
        ) {
            guard statusItemIntrospectionSetupPhase == .notStarted else { return }
            statusItemIntrospectionSetupPhase = .started
            
            // run async so that it can execute after SwiftUI sets up the NSStatusItem
            Task { @MainActor in
                let result = await block()
                statusItemIntrospectionSetupPhase = result ? .succeeded : .failed
                
                #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                if statusItemIntrospectionSetupPhase == .failed {
                    print("Timed out while searching for MenuBarExtra status item. No status item to pass to introspection block.")
                }
                #endif
            }
        }
        
        func setupStatusItemButtonStateObserver(
            _ block: @MainActor @escaping @Sendable () -> NSStatusItem.ButtonStateObserver?
        ) {
            // run async so that it can execute after SwiftUI sets up the NSStatusItem
            Task { @MainActor [self] in
                observer = block()
            }
        }
        
        func setupGlobalMouseDownMonitor(
            _ block: @MainActor @escaping @Sendable () -> Any?
        ) {
            // run async so that it can execute after SwiftUI sets up the NSStatusItem
            Task { @MainActor [self] in
                // tear down old monitor, if one exists
                if let eventsMonitor = eventsMonitor {
                    NSEvent.removeMonitor(eventsMonitor)
                }
                
                eventsMonitor = block()
            }
        }
        
        func setupWindowObservers(
            index: Int,
            didBecomeKey didBecomeKeyBlock: @MainActor @escaping @Sendable (_ window: NSWindow) -> Void,
            didResignKey didResignKeyBlock: @MainActor @escaping @Sendable (_ window: NSWindow) -> Void
        ) {
            // run async so that it can execute after SwiftUI sets up the NSStatusItem
            Task { @MainActor [self] in
                windowDidBecomeKeyObserver = MenuBarExtraUtils.newWindowObserver(
                    index: index,
                    for: NSWindow.didBecomeKeyNotification
                ) { window in didBecomeKeyBlock(window) }
                
                windowDidResignKeyObserver = MenuBarExtraUtils.newWindowObserver(
                    index: index,
                    for: NSWindow.didResignKeyNotification
                ) { window in didResignKeyBlock(window) }
                
            }
        }
    }
}

#endif
