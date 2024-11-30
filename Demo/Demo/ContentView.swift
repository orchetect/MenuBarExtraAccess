//
//  MenuBarExtraAccessDemoApp.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

struct ContentView: View {
    @Binding var isMenu0Presented: Bool
    @Binding var isMenu1Presented: Bool
    @Binding var isMenu2Presented: Bool
    @Binding var isMenu3Presented: Bool
    @Binding var isMenu4Presented: Bool
    
    @State private var dock = Dock()
    
    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 20) {
                MenuStateView(num: 4, isMenuPresented: $isMenu4Presented)
                MenuStateView(num: 3, isMenuPresented: $isMenu3Presented)
                MenuStateView(num: 2, isMenuPresented: $isMenu2Presented)
                MenuStateView(num: 1, isMenuPresented: $isMenu1Presented)
                MenuStateView(num: 0, isMenuPresented: $isMenu0Presented)
            }
            
            Toggle("Dock Icon Visible", isOn: $dock.isVisible)
            
            Text(
                """
                Try opening and closing the menus in the status bar. The toggles will update in response because the state binding is being updated. Clicking on the toggles will also open or close the menus by setting the binding value.")
                
                Note that due to how Apple implemented MenuBarExtra, menu-based status items hijack the main runloop and therefore you won't see state update here if you click on their status bar button. Additionally, they cannot be dismissed by setting the binding to false because no SwiftUI state updates occur while the menu is open - the user must select a menu item or dismiss the menu. But the menu can be opened programmatically by setting the binding to true.
                """
            )
        }
        .padding()
        .frame(minWidth: 400, minHeight: 350)
        .toggleStyle(.switch)
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
