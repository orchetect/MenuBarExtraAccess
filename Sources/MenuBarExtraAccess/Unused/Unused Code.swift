//
//  Unused Code.swift
//  MenuBarExtraAccess • https://github.com/orchetect/MenuBarExtraAccess
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import Combine

extension Scene {
    fileprivate func menuBarExtraID() -> String? {
        // Note: this is not ideal, but it's currently the ONLY way to achieve this
        // until Apple adds a 1st-party solution to MenuBarExtra state
        
        // this may require a less brittle solution if the child path may change, such as grabbing
        // String(dump: behavior) and using RegEx to find the value
        
        let m = Mirror(reflecting: self)
        
        // TODO: detect if style is .menu or .window
        
        // when using MenuBarExtra(title string, content) this is the mirror path:
        if let id = m.descendant(
            "label",
            "title",
            "storage",
            "anyTextStorage",
            "key",
            "key"
        ) as? String {
            return id
        }
        
        // this won't work. it differs when checked from NSStatusItem.menuBarExtraID
        //
        // otherwise, when using a MenuBarExtra initializer that produces Label view content:
        // we'll basically grab the hashed contents of the label
        if let anyView = m.descendant(
            "label"
        ) as? any View {
            let hashed = MenuBarExtraUtils.hash(anyView: anyView)
            print("hash:", hashed)
            return hashed
        }
        
        print("Could not determine MenuBarExtra ID")
        
        return nil
    }
}
