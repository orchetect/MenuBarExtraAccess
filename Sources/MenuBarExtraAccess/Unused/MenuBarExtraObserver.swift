//
//  MenuBarExtraObserver.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

// Note: This object is not used.

import SwiftUI
import Combine

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
    /* public */ func menuBarExtraObserver(
        index: Int,
        updating binding: Binding<Bool>
    ) -> some View {
        MenuBarExtraObserver(index: index, isMenuPresented: binding, content: self)
    }
}
