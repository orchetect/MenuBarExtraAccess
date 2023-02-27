//
//  MenuBarExtraAccess.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import Combine

@available(macOS 13.0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Scene {
    public func menuBarExtraAccess(
        index: Int = 0,
        isPresented: Binding<Bool>
    ) -> some Scene {
        // FYI: SwiftUI will reinitialize the MenuBarExtra (and this view modifier)
        // if its title/label content changes, so the stored ID is always up-to-date
        
        MenuBarExtraAccess(
            index: index,
            extraID: menuBarExtraID() ?? "",
            menuBarExtra: self,
            isMenuPresented: isPresented
        )
    }
}

@available(macOS 13.0, *)
struct MenuBarExtraAccess<Content: Scene>: Scene {
    let index: Int
    let extraID: String
    let menuBarExtra: Content
    @Binding var isMenuPresented: Bool
    
    var body: some Scene {
        menuBarExtra
            .onChange(of: isMenuPresented) { newValue in
                setPresented(newValue)
            }
            //.onChange(of: isToggling) { newValue in
            //    guard newValue == true else { return }
            //    togglePresented()
            //    isToggling = false
            //}
    }
    
    private func togglePresented() {
        MenuBarExtraUtils.togglePresented(for: .index(index))
    }
    
    private func setPresented(_ state: Bool) {
        MenuBarExtraUtils.setPresented(for: .index(index), state: state)
    }
}

extension View {
    /// Provides introspection on the underlying window presented by `MenuBarExtra`.
    public func introspectMenuBarExtraWindow(
        index: Int,
        _ block: @escaping (_ menuBarExtraWindow: NSWindow) -> Void
    ) -> some View {
        self
            .onAppear {
                guard let window = MenuBarExtraUtils.window(for: .index(index)) else {
                    print("Cannot call introspection block for status item because its window could not be found.")
                    return
                }

                print("Applying introspectMenuBarExtraWindow() for status item.")
                block(window)
            }
    }
}

@available(macOS 13.0, *)
struct MenuBarExtraObserver<Content: View>: View {
    let index: Int
    @Binding var isMenuPresented: Bool
    let content: Content
    
    @State private var stateSink: AnyCancellable?
    @State private var stateObserver: NSStatusItem.ButtonStateObserver?
    
    var body: some View {
        content
            .onAppear {
                setupObserver()
            }
    }
    
    private func setupPublisherSink() {
        guard stateSink == nil else { return }
        print("Setting up state observer for menu bar extra with index \(index)")
        
        guard let statusItem = MenuBarExtraUtils.statusItem(for: .index(index)) else {
            print("Can't register menu bar extra state observer: Can't find status item. It may not yet exist.")
            return
        }
        
        guard let publisher = statusItem.buttonStatePublisher() else {
            print("Can't register menu bar extra state observer: Can't generate publisher.")
            return
        }
        
        stateSink = publisher
            .flatMap { value in
                Just(value)
                    .tryMap { value throws -> NSControl.StateValue in value }
                    .replaceError(with: nil)
            }
            .sink(receiveValue: { value in
                let newBool = value != .off
                if isMenuPresented != newBool { isMenuPresented = newBool }
            })
    }
    
    private func setupObserver() {
        guard stateObserver == nil else { return }
        print("Setting up state observer for menu bar extra with index \(index)")
        
        guard let statusItem = MenuBarExtraUtils.statusItem(for: .index(index)) else {
            print("Can't register menu bar extra state observer: Can't find status item. It may not yet exist.")
            return
        }
        
        guard let observer = statusItem.stateObserverMenuBased({ change in
            print("NSButton state changed from: \(change.oldValue as Any), updated to: \(change.newValue as Any)")
            guard let newVal = change.newValue else { return }
            let newBool = newVal != .off
            if isMenuPresented != newBool { isMenuPresented = newBool }
        })
        else {
            print("Can't register menu bar extra state observer: Can't generate publisher.")
            return
        }
        
        stateObserver = observer
    }
}

extension View {
    public func menuBarExtraObserver(
        index: Int,
        updating binding: Binding<Bool>
    ) -> some View {
        MenuBarExtraObserver(index: index, isMenuPresented: binding, content: self)
    }
}

// MARK: - Helpers

extension Scene {
    fileprivate func menuBarExtraID() -> String? {
        // Note: this is not ideal, but it's currently the ONLY way to achieve this
        // until Apple adds a 1st-party solution to MenuBarExtra state
        
        // this may require a less brittle solution if the child path may change, such as grabbing
        // String(dump: behavior) and using RegEx to find the value
        
        let m = Mirror(reflecting: self)
        
        // TODO: detect if style is .menu or .window
        
        // when using MenuBarExtra(title string, content) this is the mirror path:
        if let id = m.descendant(
            "label",
            "title",
            "storage",
            "anyTextStorage",
            "key",
            "key"
        ) as? String {
            return id
        }
        
        // this won't work. it differs when checked from NSStatusItem.menuBarExtraID
        //
        // otherwise, when using a MenuBarExtra initializer that produces Label view content:
        // we'll basically grab the hashed contents of the label
        if let anyView = m.descendant(
            "label"
        ) as? any View {
            let hashed = MenuBarExtraUtils.hash(anyView: anyView)
            print("hash:", hashed)
            return hashed
        }
        
        print("Could not determine MenuBarExtra ID")
        
        return nil
    }
}
