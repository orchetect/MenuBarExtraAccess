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
        WindowGroup {
            ContentView(
                isMenu0Presented: $isMenu0Presented,
                isMenu1Presented: $isMenu1Presented,
                isMenu2Presented: $isMenu2Presented,
                isMenu3Presented: $isMenu3Presented,
                isMenu4Presented: $isMenu4Presented
            )
        }.windowResizability(.contentSize)
        
        // standard menu
        MenuBarExtra("Menu: Index 0", systemImage: "0.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
        }
        .menuBarExtraAccess(index: 0, isPresented: $isMenu0Presented)
        .menuBarExtraStyle(.menu)
        
        // standard menu using named image
        MenuBarExtra("Menu: Index 1", image: "1.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
            Button("Menu Item C") { print("Menu Item C") }
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
        HStack(spacing: 20) {
            MenuStateView(num: 4, isMenuPresented: $isMenu4Presented)
            MenuStateView(num: 3, isMenuPresented: $isMenu3Presented)
            MenuStateView(num: 2, isMenuPresented: $isMenu2Presented)
            MenuStateView(num: 1, isMenuPresented: $isMenu1Presented)
            MenuStateView(num: 0, isMenuPresented: $isMenu0Presented)
        }
        .padding()
        .frame(minWidth: 380, minHeight: 160)
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
