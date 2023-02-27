//
//  MenuBarExtra Window Introspection.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

extension View {
    /// Provides introspection on the underlying window presented by `MenuBarExtra`.
    public func introspectMenuBarExtraWindow(
        index: Int,
        _ block: @escaping (_ menuBarExtraWindow: NSWindow) -> Void
    ) -> some View {
        self
            .onAppear {
                guard let window = MenuBarExtraUtils.window(for: .index(index)) else {
                    print("Cannot call introspection block for status item because its window could not be found.")
                    return
                }
                
                block(window)
            }
    }
}
