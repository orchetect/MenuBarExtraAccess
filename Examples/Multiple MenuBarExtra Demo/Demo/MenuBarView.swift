//
//  MenuBarView.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

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
