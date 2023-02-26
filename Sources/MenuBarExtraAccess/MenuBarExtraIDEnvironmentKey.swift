//
//  MenuBarExtraIDEnvironmentKey.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

extension EnvironmentValues {
    /// MenuBarExtra ID.
    var menuBarExtraID: String {
        get { self[MenuBarExtraIDEnvironmentKey.self] }
        set { self[MenuBarExtraIDEnvironmentKey.self] = newValue }
    }
}

private struct MenuBarExtraIDEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = ""
}
