//
//  StatusItemIdentity.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

enum StatusItemIdentity: Equatable, Hashable {
    case index(Int)
    case id(String)
}

extension StatusItemIdentity: CustomStringConvertible {
    var description: String {
        switch self {
        case let .index(int):
            return "index \(int)"
        case let .id(string):
            return "ID \"\(string)\""
        }
    }
}

#endif
