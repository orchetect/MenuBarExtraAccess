//
//  MenuBarExtraAccessDemoApp.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import MenuBarExtraAccess

@main
struct MenuBarExtraAccessDemoApp: App {
    @State var isMenu1Presented: Bool = false
    @State var isMenu2Presented: Bool = false
    @State var isMenu3Presented: Bool = false
    @State var isMenu4Presented: Bool = false
    @State var isMenu5Presented: Bool = false
    
    var body: some Scene {
        // item 1: standard menu
        MenuBarExtra("Menu 1", systemImage: "1.circle.fill") {
            Button("Menu Item 1") { print("Menu Item 1") }
            Button("Menu Item 2") { print("Menu Item 2") }
        }
        .menuBarExtraAccess(index: 0, isPresented: $isMenu1Presented)
        .menuBarExtraStyle(.menu)
        
        // item 2: standard menu using named image
        MenuBarExtra("Menu 2", image: "2.circle.fill") {
            Button("Menu Item 1") { print("Menu Item 1") }
            Button("Menu Item 2") { print("Menu Item 2") }
            Button("Menu Item 3") { print("Menu Item 3") }
        }
        .menuBarExtraAccess(index: 1, isPresented: $isMenu2Presented)
        .menuBarExtraStyle(.menu)
        
        // item 3: window-style using systemImage
        MenuBarExtra("Window 1", systemImage: "3.circle.fill") {
            MenuBarView(isMenuPresented: $isMenu3Presented)
        }
        .menuBarExtraAccess(index: 2, isPresented: $isMenu3Presented)
        .menuBarExtraStyle(.window)
        
        // item 4: window-style using named image
        MenuBarExtra("Window 2", image: "4.circle.fill") {
            MenuBarView(isMenuPresented: $isMenu4Presented)
                .introspectMenuBarExtraWindow(index: 3) { window in
                    window.animationBehavior = .alertPanel // just for fun, but looks a bit weird
                }
        }
        .menuBarExtraAccess(index: 3, isPresented: $isMenu4Presented)
        .menuBarExtraStyle(.window)
        
        // item 5: window-style using custom label
        MenuBarExtra {
            MenuBarView(isMenuPresented: $isMenu5Presented)
        } label: {
            Image(systemName: "5.circle.fill")
        }
        .menuBarExtraAccess(index: 4, isPresented: $isMenu5Presented)
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(
                isMenu1Presented: $isMenu1Presented,
                isMenu2Presented: $isMenu2Presented,
                isMenu3Presented: $isMenu3Presented,
                isMenu4Presented: $isMenu4Presented,
                isMenu5Presented: $isMenu5Presented
            )
        }.windowResizability(.contentSize)
    }
}

struct MenuBarView: View {
    @Binding var isMenuPresented: Bool
    
    var body: some View {
        VStack {
            Button("Close Menu") {
                isMenuPresented = false
            }
        }
        .frame(width: 450, height: 200)
    }
}

struct SettingsView: View {
    @Binding var isMenu1Presented: Bool
    @Binding var isMenu2Presented: Bool
    @Binding var isMenu3Presented: Bool
    @Binding var isMenu4Presented: Bool
    @Binding var isMenu5Presented: Bool
    
    var body: some View {
        VStack {
            MenuStateView(num: 1, isMenuPresented: $isMenu1Presented)
            MenuStateView(num: 2, isMenuPresented: $isMenu2Presented)
            MenuStateView(num: 3, isMenuPresented: $isMenu3Presented)
            MenuStateView(num: 4, isMenuPresented: $isMenu4Presented)
            MenuStateView(num: 5, isMenuPresented: $isMenu5Presented)
        }
        .padding()
        .frame(minWidth: 400)
    }
    
    struct MenuStateView: View {
        let num: Int
        @Binding var isMenuPresented: Bool
        
        var body: some View {
            HStack {
                Text("Menu \(num):")
                Button("Open") { isMenuPresented = true }
                    .bold(isMenuPresented)
                
                Button("Close") { isMenuPresented = false }
                    .bold(!isMenuPresented)
                
                Button("Toggle") {
                    isMenuPresented.toggle()
                }
                
                Button("Open Then Close") {
                    // TODO: this won't work for a menu-based MenuBarExtra because the popup menu blocks the runloop
                    DispatchQueue.main.async {
                        isMenuPresented = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isMenuPresented = false
                    }
                }
            }
        }
    }
}
