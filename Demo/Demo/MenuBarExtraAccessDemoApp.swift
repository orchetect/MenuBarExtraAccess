//
//  MenuBarExtraAccessDemoApp.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import MenuBarExtraAccess

@main
struct MenuBarExtraAccessDemoApp: App {
    @State var isMenu0Presented: Bool = false
    @State var isMenu1Presented: Bool = false
    @State var isMenu2Presented: Bool = false
    @State var isMenu3Presented: Bool = false
    @State var isMenu4Presented: Bool = false
    
    @State var menu0StatusItem: NSStatusItem?
    
    var body: some Scene {
        // MARK: - Info Window
        
        WindowGroup {
            ContentView(
                isMenu0Presented: $isMenu0Presented,
                isMenu1Presented: $isMenu1Presented,
                isMenu2Presented: $isMenu2Presented,
                isMenu3Presented: $isMenu3Presented,
                isMenu4Presented: $isMenu4Presented
            )
        }
        .windowResizability(.contentSize)
        
        // MARK: - MenuBarExtra Scenes
        
        // 💡 NOTE: There are 5 menu extras here simply to demonstrate (and test)
        // various implementations of MenuBarExtra
        
        // 💡 NOTE: Even if the menu extras get reordered in the menu bar by the user (by holding Cmd
        // and dragging them), the indexes still remain consistent with the order in which
        // the MenuBarExtra definitions appear below.
        
        // MARK: Standard Menu
        
        MenuBarExtra("Menu: Index 0", systemImage: "0.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
        }
        .menuBarExtraAccess(index: 0, isPresented: $isMenu0Presented) { statusItem in
            // can do one-time setup of NSStatusItem here or if access to it
            // is needed later, it may be stored in a local state var like this:
            menu0StatusItem = statusItem
        }
        .menuBarExtraStyle(.menu)
        
        // MARK: Standard menu using named image
        
        MenuBarExtra("Menu: Index 1", image: "1.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
            Button("Menu Item C") { print("Menu Item C") }
            Button("Toggle Menu 0 Disabled State") {
                menu0StatusItem?.button?.appearsDisabled.toggle()
            }
        }
        .menuBarExtraAccess(index: 1, isPresented: $isMenu1Presented)
        .menuBarExtraStyle(.menu)
        
        // MARK: Window-style using systemImage
        
        MenuBarExtra("Menu: Index 2", systemImage: "2.circle.fill") {
            MenuBarView(index: 2, isMenuPresented: $isMenu2Presented)
        }
        .menuBarExtraAccess(index: 2, isPresented: $isMenu2Presented)
        .menuBarExtraStyle(.window)
        
        // MARK: Window-style using named image
        
        MenuBarExtra("Menu: Index 3", image: "3.circle.fill") {
            MenuBarView(index: 3, isMenuPresented: $isMenu3Presented)
                .introspectMenuBarExtraWindow(index: 3) { window in
                    window.alphaValue = 0.5
                }
        }
        .menuBarExtraAccess(index: 3, isPresented: $isMenu3Presented)
        .menuBarExtraStyle(.window)
        
        // MARK: Window-style using custom label
        
        MenuBarExtra {
            MenuBarView(index: 4, isMenuPresented: $isMenu4Presented)
        } label: {
            Image(systemName: "4.circle.fill")
            Text("Four")
        }
        .menuBarExtraAccess(index: 4, isPresented: $isMenu4Presented)
        .menuBarExtraStyle(.window)
    }
}
