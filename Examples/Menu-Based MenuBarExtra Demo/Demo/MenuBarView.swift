//
//  MenuBarView.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        VStack(spacing: 40) {
            Button("Menu Item A") {
                print("Menu item A selected.")
            }
            Button("Menu Item B") {
                print("Menu item B selected.")
            }
        }
    }
}
