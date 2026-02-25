//
//  ContentView.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 40) {
            HStack(spacing: 20) {
                VStack(alignment: .trailing, spacing: 20) {
                    Text("")
                    Text("Presented:")
                    Text("Enabled:")
                }
                MenuStateView(num: 4, menuState: $viewModel.menu4)
                MenuStateView(num: 3, menuState: $viewModel.menu3)
                MenuStateView(num: 2, menuState: $viewModel.menu2)
                MenuStateView(num: 1, menuState: $viewModel.menu1)
                MenuStateView(num: 0, menuState: $viewModel.menu0)
            }
            
            Toggle("Dock Icon Visible", isOn: $viewModel.isDockVisible)
            
            InfoView()
        }
        .padding()
        .toggleStyle(.switch)
        .multilineTextAlignment(.center)
        .frame(minWidth: 720, minHeight: 600)
    }
}

extension ContentView {
    struct MenuStateView: View {
        let num: Int
        @Binding var menuState: ViewModel.MenuState
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "\(num).circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Toggle("", isOn: $menuState.isPresented)
                    .toggleStyle(.switch)
                    .labelsHidden()
                
                Toggle("", isOn: $menuState.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
        }
    }
}

extension ContentView {
    struct InfoView: View {
        var body: some View {
            Form {
                HStack(alignment: .top) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .frame(width: 20)
                    Text(
                        """
                        Try opening and closing the menus in the menu bar. \
                        The Presented toggles will update in response because the state binding is being updated. \
                        Clicking on the same toggles will also open or close the menus by setting the binding value.
                        """
                    )
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .frame(width: 20)
                    Text("Manually reordering the menu extras by `⌘`+dragging them still preserves each menu's index and associated bindings.")
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(
                            """
                            Note that due to how Apple implemented `MenuBarExtra`, menu-based status items hijack the \
                            main runloop and therefore you won't see state update here if you click on the menu extra item.
                            """
                        )
                        Text(
                            """
                            Additionally, they cannot be dismissed by setting the binding to `false` because no SwiftUI \
                            state updates occur while the menu is open - the user must select a menu item or dismiss the menu \
                            by clicking outside of it.
                            """
                        )
                        Text(
                            """
                            This means that the binding will not transition to `true` when the user opens the menu. \
                            However, the menu can still be opened programmatically by setting the binding to `true`.
                            """
                        )
                    }
                }
            }
            .formStyle(.grouped)
        }
    }
}
