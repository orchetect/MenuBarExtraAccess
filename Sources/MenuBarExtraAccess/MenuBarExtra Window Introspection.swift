//
//  MenuBarExtra Window Introspection.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import SwiftUI

@MainActor // required for Xcode 15 builds
extension View {
    /// Provides introspection on the underlying window presented by `MenuBarExtra`.
    /// Add this view modifier to the top level of the View that occupies the `MenuBarExtra` content.
    /// If more than one MenuBarExtra are used in the app, provide the sequential index number of the `MenuBarExtra`.
    public func introspectMenuBarExtraWindow(
        index: Int = 0,
        _ block: @escaping (_ window: NSWindow) -> Void
    ) -> some View {
        self
            .onAppear {
                guard let window = MenuBarExtraUtils.window(for: .index(index)) else {
                    #if MENUBAREXTRAACCESS_DEBUG_LOGGING
                    print("Cannot call introspection block for status item because its window could not be found.")
                    #endif
                    
                    return
                }
                
                block(window)
            }
    }
}

#endif
