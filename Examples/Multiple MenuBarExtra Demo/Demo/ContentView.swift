//
//  ContentView.swift
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
    
    @Binding var isStatusItem0Enabled: Bool
    @Binding var isStatusItem1Enabled: Bool
    @Binding var isStatusItem2Enabled: Bool
    @Binding var isStatusItem3Enabled: Bool
    @Binding var isStatusItem4Enabled: Bool
    
    @ObservedObject private var dock = Dock()
    
    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 20) {
                VStack(alignment: .trailing, spacing: 20) {
                    Text("")
                    Text("Presented:")
                    Text("Enabled:")
                }
                MenuStateView(num: 4, isMenuPresented: $isMenu4Presented, isStatusItemEnabled: $isStatusItem4Enabled)
                MenuStateView(num: 3, isMenuPresented: $isMenu3Presented, isStatusItemEnabled: $isStatusItem3Enabled)
                MenuStateView(num: 2, isMenuPresented: $isMenu2Presented, isStatusItemEnabled: $isStatusItem2Enabled)
                MenuStateView(num: 1, isMenuPresented: $isMenu1Presented, isStatusItemEnabled: $isStatusItem1Enabled)
                MenuStateView(num: 0, isMenuPresented: $isMenu0Presented, isStatusItemEnabled: $isStatusItem0Enabled)
            }
            
            Toggle("Dock Icon Visible", isOn: $dock.isVisible)
            
            Text(
                """
                Try opening and closing the menus in the menu bar. The Presented toggles will update in response because the state binding is being updated. Clicking on the same toggles will also open or close the menus by setting the binding value.
                
                Manually reordering the menu extras by Cmd+dragging them still preserves each menu's index and associated bindings.
                
                Note that due to how Apple implemented `MenuBarExtra`, menu-based status items hijack the main runloop and therefore you won't see state update here if you click on the menu extra item. Additionally, they cannot be dismissed by setting the binding to `false` because no SwiftUI state updates occur while the menu is open - the user must select a menu item or dismiss the menu by clicking outside of it. This means that the binding will not transition to `true` when the user opens the menu. However, the menu can still be opened programmatically by setting the binding to `true`.
                """
            )
        }
        .padding()
        .toggleStyle(.switch)
        .multilineTextAlignment(.center)
        .frame(minWidth: 550, minHeight: 500)
    }
    
    struct MenuStateView: View {
        let num: Int
        @Binding var isMenuPresented: Bool
        @Binding var isStatusItemEnabled: Bool
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "\(num).circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Toggle("", isOn: $isMenuPresented)
                    .toggleStyle(.switch)
                    .labelsHidden()
                
                Toggle("", isOn: $isStatusItemEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
        }
    }
}
