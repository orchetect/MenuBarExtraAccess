//
//  ViewModel.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import AppKit
import Foundation

@MainActor @Observable final class ViewModel {
    var menu0 = MenuState(isPresented: false, isEnabled: true)
    var menu1 = MenuState(isPresented: false, isEnabled: true)
    var menu2 = MenuState(isPresented: false, isEnabled: false)
    var menu3 = MenuState(isPresented: false, isEnabled: true)
    var menu4 = MenuState(isPresented: false, isEnabled: true)
    
    var menu0StatusItem: NSStatusItem? = nil
    
    init() { }
}

// MARK: - Computed Non-Observable Properties

extension ViewModel {
    var isDockVisible: Bool {
        get { NSApplication.shared.activationPolicy() == .regular }
        set { NSApplication.shared.setActivationPolicy(newValue ? .regular : .accessory) }
    }
}

// MARK: - Model Types

extension ViewModel {
    struct MenuState: Equatable, Hashable, Sendable {
        var isPresented: Bool
        var isEnabled: Bool
        
        init(isPresented: Bool, isEnabled: Bool) {
            self.isPresented = isPresented
            self.isEnabled = isEnabled
        }
    }
}
