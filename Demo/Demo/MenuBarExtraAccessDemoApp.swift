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
    
    var body: some Scene {
        // standard menu
        MenuBarExtra("Menu Index 0", systemImage: "0.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
        }
        .menuBarExtraAccess(index: 0, isPresented: $isMenu0Presented)
        .menuBarExtraStyle(.menu)
        
        // standard menu using named image
        MenuBarExtra("Menu Index 1", image: "1.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
            Button("Menu Item C") { print("Menu Item C") }
        }
        .menuBarExtraAccess(index: 1, isPresented: $isMenu1Presented)
        .menuBarExtraStyle(.menu)
        
        // window-style using systemImage
        MenuBarExtra("Menu Index 2", systemImage: "2.circle.fill") {
            MenuBarView(index: 2, isMenuPresented: $isMenu2Presented)
        }
        .menuBarExtraAccess(index: 2, isPresented: $isMenu2Presented)
        .menuBarExtraStyle(.window)
        
        // window-style using named image
        MenuBarExtra("Menu Index 3", image: "3.circle.fill") {
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
        }
        .menuBarExtraAccess(index: 4, isPresented: $isMenu4Presented)
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(
                isMenu0Presented: $isMenu0Presented,
                isMenu1Presented: $isMenu1Presented,
                isMenu2Presented: $isMenu2Presented,
                isMenu3Presented: $isMenu3Presented,
                isMenu4Presented: $isMenu4Presented
            )
        }.windowResizability(.contentSize)
    }
}

struct MenuBarView: View {
    let index: Int
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
    @Binding var isMenu0Presented: Bool
    @Binding var isMenu1Presented: Bool
    @Binding var isMenu2Presented: Bool
    @Binding var isMenu3Presented: Bool
    @Binding var isMenu4Presented: Bool
    
    var body: some View {
        VStack {
            MenuStateView(num: 0, isMenuPresented: $isMenu0Presented)
            MenuStateView(num: 1, isMenuPresented: $isMenu1Presented)
            MenuStateView(num: 2, isMenuPresented: $isMenu2Presented)
            MenuStateView(num: 3, isMenuPresented: $isMenu3Presented)
            MenuStateView(num: 4, isMenuPresented: $isMenu4Presented)
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
