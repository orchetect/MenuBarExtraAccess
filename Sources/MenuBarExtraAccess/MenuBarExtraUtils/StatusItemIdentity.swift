//
//  MenuBarExtraUtils.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

enum StatusItemIdentity: Equatable, Hashable {
    case index(Int)
    case id(String)
}

extension StatusItemIdentity: CustomStringConvertible {
    var description: String {
        switch self {
        case .index(let int):
            return "index \(int)"
        case .id(let string):
            return "ID \"\(string)\""
        }
    }
}

#endif
