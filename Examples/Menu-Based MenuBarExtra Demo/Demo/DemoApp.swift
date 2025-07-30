//
//  DemoApp.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import MenuBarExtraAccess

@main
struct DemoApp: App {
    @State var isMenuExtraPresented: Bool = false
    @State var isMenuExtraEnabled: Bool = true
    @State var statusItem: NSStatusItem?
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                isMenuExtraPresented: $isMenuExtraPresented,
                isMenuExtraEnabled: $isMenuExtraEnabled
            )
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "bubble.left.fill")
        }
        .menuBarExtraAccess(isPresented: $isMenuExtraPresented, isEnabled: $isMenuExtraEnabled) { statusItem in
            // status item can be modified here if needed,
            // or stored in a State var for later access.
            // note that this is entirely optional and provided for convenience.
            self.statusItem = statusItem
        }
        .menuBarExtraStyle(.menu)
    }
}
