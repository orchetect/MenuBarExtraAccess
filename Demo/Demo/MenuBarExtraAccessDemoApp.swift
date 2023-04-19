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
        WindowGroup {
            ContentView(
                isMenu0Presented: $isMenu0Presented,
                isMenu1Presented: $isMenu1Presented,
                isMenu2Presented: $isMenu2Presented,
                isMenu3Presented: $isMenu3Presented,
                isMenu4Presented: $isMenu4Presented
            )
        }.windowResizability(.contentSize)
        
        // 💡 NOTE: There are 5 menu extras here simply to demonstrate (and test)
        // various implementations of MenuBarExtra
        
        // 💡 NOTE: Even if the menu extras get reordered in the menu bar by the user (by holding Cmd
        // and dragging them), the indexes still remain consistent with the order in which
        // the MenuBarExtra definitions appear below.
        
        // standard menu
        MenuBarExtra("Menu: Index 0", systemImage: "0.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
        }
        .menuBarExtraAccess(index: 0, isPresented: $isMenu0Presented) { statusItem in
            // can do one-time setup of NSStatusItem here
            statusItem.button?.appearsDisabled = true
            
            // or if access to the NSStatusItem is needed later, it may be stored in a local state var
            menu0StatusItem = statusItem
        }
        .menuBarExtraStyle(.menu)
        
        // standard menu using named image
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
        
        // window-style using systemImage
        MenuBarExtra("Menu: Index 2", systemImage: "2.circle.fill") {
            MenuBarView(index: 2, isMenuPresented: $isMenu2Presented)
        }
        .menuBarExtraAccess(index: 2, isPresented: $isMenu2Presented)
        .menuBarExtraStyle(.window)
        
        // window-style using named image
        MenuBarExtra("Menu: Index 3", image: "3.circle.fill") {
            MenuBarView(index: 3, isMenuPresented: $isMenu3Presented)
                .introspectMenuBarExtraWindow(index: 3) { window in
                    // just to demonstrate introspection, but looks a bit weird
                    window.animationBehavior = .alertPanel
                }
        }
        .menuBarExtraAccess(index: 3, isPresented: $isMenu3Presented)
        .menuBarExtraStyle(.window)
        
        // window-style using custom label
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

struct MenuBarView: View {
    let index: Int
    @Binding var isMenuPresented: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "\(index).circle.fill")
                .resizable()
                .foregroundColor(.secondary)
                .frame(width: 80, height: 80)
            Button("Close Menu") {
                isMenuPresented = false
            }
        }
        .padding()
        .frame(width: 250, height: 300)
    }
}

struct ContentView: View {
    @Binding var isMenu0Presented: Bool
    @Binding var isMenu1Presented: Bool
    @Binding var isMenu2Presented: Bool
    @Binding var isMenu3Presented: Bool
    @Binding var isMenu4Presented: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 20) {
                MenuStateView(num: 4, isMenuPresented: $isMenu4Presented)
                MenuStateView(num: 3, isMenuPresented: $isMenu3Presented)
                MenuStateView(num: 2, isMenuPresented: $isMenu2Presented)
                MenuStateView(num: 1, isMenuPresented: $isMenu1Presented)
                MenuStateView(num: 0, isMenuPresented: $isMenu0Presented)
            }
            
            Text("""
                Try opening and closing the menus in the status bar. The toggles will update in response because the state binding is being updated. Clicking on the toggles will also open or close the menus by setting the binding value.")
                
                Note that due to how Apple implemented MenuBarExtra, menu-based status items hijack the main runloop and therefore you won't see state update here if you click on their status bar button. Additionally, they cannot be dismissed by setting the binding to false because no SwiftUI date updates occur while the menu is open - the user must select a menu item or dismiss the menu. But the menu can be opened programmatically by setting the binding to true.
                """
            )
        }
        .padding()
        .frame(minWidth: 400, minHeight: 350)
    }
    
    struct MenuStateView: View {
        let num: Int
        @Binding var isMenuPresented: Bool
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "\(num).circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                Toggle("", isOn: $isMenuPresented)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
        }
    }
}
