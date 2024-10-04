//
//  NSEvent Extensions.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit

extension NSEvent.EventType: @retroactive CustomStringConvertible {
    @_disfavoredOverload
    public var description: String {
        switch self {
        case .leftMouseDown: return "leftMouseDown"
        case .leftMouseUp: return "leftMouseUp"
        case .rightMouseDown: return "rightMouseDown"
        case .rightMouseUp: return "rightMouseUp"
        case .mouseMoved: return "mouseMoved"
        case .leftMouseDragged: return "leftMouseDragged"
        case .rightMouseDragged: return "rightMouseDragged"
        case .mouseEntered: return "mouseEntered"
        case .mouseExited: return "mouseExited"
        case .keyDown: return "keyDown"
        case .keyUp: return "keyUp"
        case .flagsChanged: return "flagsChanged"
        case .appKitDefined: return "appKitDefined"
        case .systemDefined: return "systemDefined"
        case .applicationDefined: return "applicationDefined"
        case .periodic: return "periodic"
        case .cursorUpdate: return "cursorUpdate"
        case .scrollWheel: return "scrollWheel"
        case .tabletPoint: return "tabletPoint"
        case .tabletProximity: return "tabletProximity"
        case .otherMouseDown: return "otherMouseDown"
        case .otherMouseUp: return "otherMouseUp"
        case .otherMouseDragged: return "otherMouseDragged"
        case .gesture: return "gesture"
        case .magnify: return "magnify"
        case .swipe: return "swipe"
        case .rotate: return "rotate"
        case .beginGesture: return "beginGesture"
        case .endGesture: return "endGesture"
        case .smartMagnify: return "smartMagnify"
        case .quickLook: return "quickLook"
        case .pressure: return "pressure"
        case .directTouch: return "directTouch"
        case .changeMode: return "changeMode"
        @unknown default:
            assertionFailure("Unhandled `NSEvent.EventType` case with raw value: \(rawValue)")
            return "\(rawValue)"
        }
    }
}

#endif
