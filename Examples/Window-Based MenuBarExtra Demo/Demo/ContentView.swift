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
            
            Text("This window-based menubar extra has been added to the menubar.")
            
            Divider()
            
            HStack(spacing: 20) {
                Toggle("Enabled", isOn: $isMenuExtraEnabled)
                    .toggleStyle(.switch)
                
                Toggle("Presented", isOn: $isMenuExtraPresented)
                    .toggleStyle(.switch)
            }
            
            Divider()
            
            VStack(spacing: 10) {
                Text("Try opening and closing the menu in the menu bar. The Presented toggle will update in response because the state binding is being updated.")
                Text("Clicking on the Presented toggle will also open or close the menu by setting the binding value.")
            }
        }
        .padding()
        .toggleStyle(.switch)
        .multilineTextAlignment(.center)
        .frame(minWidth: 450, maxWidth: 500, minHeight: 400, maxHeight: 600)
    }
}
