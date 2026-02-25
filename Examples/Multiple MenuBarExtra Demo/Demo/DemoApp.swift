//
//  DemoApp.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import MenuBarExtraAccess

@main
struct DemoApp: App {
    @State var viewModel = ViewModel()
    
    var body: some Scene {
        // MARK: - Demo Window
        
        WindowGroup {
            ContentView()
                .environment(viewModel)
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
            isPresented: $viewModel.menu0.isPresented,
            isEnabled: $viewModel.menu0.isEnabled
        ) { statusItem in
            // can do one-time setup of NSStatusItem here or if access to it
            // is needed later, it may be stored in a local state var like this:
            viewModel.menu0StatusItem = statusItem
        }
        .menuBarExtraStyle(.menu)
        
        // MARK: Standard menu using named image
        
        MenuBarExtra("Menu: Index 1", image: "1.circle.fill") {
            Button("Menu Item A") { print("Menu Item A") }
            Button("Menu Item B") { print("Menu Item B") }
        }
        .menuBarExtraAccess(index: 1, isPresented: $viewModel.menu1.isPresented, isEnabled: $viewModel.menu1.isEnabled)
        .menuBarExtraStyle(.menu)
        
        // MARK: Window-style using systemImage
        
        MenuBarExtra("Menu: Index 2", systemImage: "2.circle.fill") {
            MenuBarView(index: 2, isMenuPresented: $viewModel.menu2.isPresented)
        }
        .menuBarExtraAccess(index: 2, isPresented: $viewModel.menu2.isPresented, isEnabled: $viewModel.menu2.isEnabled)
        .menuBarExtraStyle(.window)
        
        // MARK: Window-style using named image
        
        MenuBarExtra("Menu: Index 3", image: "3.circle.fill") {
            MenuBarView(index: 3, isMenuPresented: $viewModel.menu3.isPresented)
                .introspectMenuBarExtraWindow(index: 3) { window in
                    // window properties can be modified here if needed, for example:
                    window.alphaValue = 0.5
                }
        }
        .menuBarExtraAccess(index: 3, isPresented: $viewModel.menu3.isPresented, isEnabled: $viewModel.menu3.isEnabled)
        .menuBarExtraStyle(.window)
        
        // MARK: Window-style using custom label
        
        MenuBarExtra {
            MenuBarView(index: 4, isMenuPresented: $viewModel.menu4.isPresented)
        } label: {
            Image(systemName: "4.circle.fill")
            Text("Four")
        }
        .menuBarExtraAccess(index: 4, isPresented: $viewModel.menu4.isPresented, isEnabled: $viewModel.menu4.isEnabled)
        .menuBarExtraStyle(.window)
    }
}
