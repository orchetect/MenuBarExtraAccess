//
//  ContentView.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

struct ContentView: View {
    @Binding var isMenuExtraPresented: Bool
    @Binding var isMenuExtraEnabled: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.secondary)
                .frame(width: 80, height: 80)
            
            Text("This menu-based menubar extra has been added to the menubar.")
            
            Divider()
            
            HStack(spacing: 20) {
                Toggle("Enabled", isOn: $isMenuExtraEnabled)
                    .toggleStyle(.switch)
                
                Toggle("Presented", isOn: $isMenuExtraPresented)
                    .toggleStyle(.switch)
            }
            
            Divider()
            
            InfoView()
        }
        .padding()
        .toggleStyle(.switch)
        .multilineTextAlignment(.center)
        .frame(minWidth: 550, maxWidth: 600, minHeight: 520, maxHeight: 600)
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
                    Text("Clicking on the Presented toggle will open the menu by setting the binding value to `true`.")
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
