//
//  Dock.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftUI

@Observable @MainActor final class Dock {
    var isVisible: Bool {
        get { NSApplication.shared.activationPolicy() == .regular }
        set { NSApplication.shared.setActivationPolicy(newValue ? .regular : .accessory) }
    }
}
