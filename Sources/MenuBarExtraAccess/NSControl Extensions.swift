//
//  NSControl Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit

extension NSControl.StateValue: @retroactive CustomStringConvertible {
    @_disfavoredOverload
    public var description: String {
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
