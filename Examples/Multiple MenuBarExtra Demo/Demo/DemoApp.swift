//
//  DemoApp.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import MenuBarExtraAccess

@main
struct DemoApp: App {
    @State var isMenu0Presented: Bool = false
    @State var isMenu1Presented: Bool = false
    @State var isMenu2Presented: Bool = false
    @State var isMenu3Presented: Bool = false
    @State var isMenu4Presented: Bool = false
    
    @State var isStatusItem0Enabled: Bool = true
    @State var isStatusItem1Enabled: Bool = true
    @State var isStatusItem2Enabled: Bool = false
    @State var isStatusItem3Enabled: Bool = true
    @State var isStatusItem4Enabled: Bool = true
    
    @State var menu0StatusItem: NSStatusItem?
    
    var body: some Scene {
        // MARK: - Demo Window
        
        WindowGroup {
            ContentView(
                isMenu0Presented: $isMenu0Presented,
                isMenu1Presented: $isMenu1Presented,
                isMenu2Presented: $isMenu2Presented,
                isMenu3Presented: $isMenu3Presented,
                isMenu4Presented: $isMenu4Presented,
                isStatusItem0Enabled: $isStatusItem0Enabled,
                isStatusItem1Enabled: $isStatusItem1Enabled,
                isStatusItem2Enabled: $isStatusItem2Enabled,
                isStatusItem3Enabled: $isStatusItem3Enabled,
                isStatusItem4Enabled: $isStatusItem4Enabled
            )
        }
        .windowResizability(.contentSize)
        
        // MARK: - MenuBarExtra Scenes
        
        // 💡 NOTE:
        // - There are 5 menu extras here simply to demonstrate (and test)
        //   various implementations of MenuBarExtra
        // - Even if the menu extras get reordered in the menu bar by the user (by holding Cmd
        //   and dragging them), the indexes still remain consistent with the order in which
        //   the MenuBarExtra definitions appear below.
        
        // MARK: Standard Menu
        
        MenuBarExtra("Menu: Index 0", systemImage: "0.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
        }
        .menuBarExtraAccess(
            index: 0,
            isPresented: $isMenu0Presented,
            isEnabled: $isStatusItem0Enabled
        ) { statusItem in
            // can do one-time setup of NSStatusItem here or if access to it
            // is needed later, it may be stored in a local state var like this:
            menu0StatusItem = statusItem
        }
        .menuBarExtraStyle(.menu)
        
        // MARK: Standard menu using named image
        
        MenuBarExtra("Menu: Index 1", image: "1.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
        }
        .menuBarExtraAccess(index: 1, isPresented: $isMenu1Presented, isEnabled: $isStatusItem1Enabled)
        .menuBarExtraStyle(.menu)
        
        // MARK: Window-style using systemImage
        
        MenuBarExtra("Menu: Index 2", systemImage: "2.circle.fill") {
            MenuBarView(index: 2, isMenuPresented: $isMenu2Presented)
        }
        .menuBarExtraAccess(index: 2, isPresented: $isMenu2Presented, isEnabled: $isStatusItem2Enabled)
        .menuBarExtraStyle(.window)
        
        // MARK: Window-style using named image
        
        MenuBarExtra("Menu: Index 3", image: "3.circle.fill") {
            MenuBarView(index: 3, isMenuPresented: $isMenu3Presented)
                .introspectMenuBarExtraWindow(index: 3) { window in
                    // window properties can be modified here if needed, for example:
                    window.alphaValue = 0.5
                }
        }
        .menuBarExtraAccess(index: 3, isPresented: $isMenu3Presented, isEnabled: $isStatusItem3Enabled)
        .menuBarExtraStyle(.window)
        
        // MARK: Window-style using custom label
        
        MenuBarExtra {
            MenuBarView(index: 4, isMenuPresented: $isMenu4Presented)
        } label: {
            Image(systemName: "4.circle.fill")
            Text("Four")
        }
        .menuBarExtraAccess(index: 4, isPresented: $isMenu4Presented, isEnabled: $isStatusItem4Enabled)
        .menuBarExtraStyle(.window)
    }
}
