//
//  NSControl Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit

extension NSControl.StateValue {
    @_disfavoredOverload
    public var name: String {
        switch self {
        case .on: 
            return "on"
        case .off:
            return "off"
        case .mixed:
            return "mixed"
        default:
            return "unknown"
        }
    }
}

#endif
