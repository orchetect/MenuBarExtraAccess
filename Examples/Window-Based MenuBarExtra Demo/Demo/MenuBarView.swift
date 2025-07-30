//
//  MenuBarView.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

struct MenuBarView: View {
    @Binding var isMenuPresented: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Button("Close Menu") {
                isMenuPresented = false
            }
        }
        .padding()
        .frame(width: 250, height: 300)
    }
}
