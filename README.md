# MenuBarExtraAccess

[![Platforms - macOS 13.0](https://img.shields.io/badge/platforms-macOS%2013.0-lightgrey.svg?style=flat)](https://developer.apple.com/swift) ![Swift 5.7-5.8](https://img.shields.io/badge/Swift-5.7–5.8-orange.svg?style=flat) [![Xcode 14](https://img.shields.io/badge/Xcode-14-blue.svg?style=flat)](https://developer.apple.com/swift) [![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/orchetect/MenuBarExtraAccess/blob/main/LICENSE)

#### **Gives you *Extra* access to SwiftUI `MenuBarExtra`.**

- Programmatically hide, show, or toggle the menu (by way of a Bool binding)
- Access to the underlying `NSStatusItem`
- Access to the underlying `NSWindow` (when using the `.window` style)
- Works with one or [multiple](#Multiple-MenuBarExtra) `MenuBarExtra`
- Works with both [`menu`](#Standard-Menu-Style) and [`window`](#Window-Style) based styles (see [Known Issues](#Known-Issues))

#### Why?

There is no 1st-party MenuBarExtra API to obtain or set the menu presentation state, access the status item, or access the popup's NSWindow. (As of Xcode 14.3 / SwiftUI 4)

#### Library Features

- A new `.menuBarExtraAccess(isPresented:) { statusItem in }` scene modifier with
  - a binding to hide/show/toggle the menu, and
  - direct access to the `NSStatusItem` if needed
- A new `.introspectMenuBarExtraWindow { window in }` view modifier passing in the `NSWindow` reference
- Window-based menu extra status items now remain highlighted while the window is open so it feels more like a native menu
- No private API used, so it's Mac App Store safe

## Getting Started

The library is available as a Swift Package Manager (SPM) package.

Use the URL `https://github.com/orchetect/MenuBarExtraAccess` when adding the library to a project or Swift package.

Then import the library:

```swift
import SwiftUI
import MenuBarExtraAccess
```

### Standard Menu Style

An example of showing the menu extra menu by clicking a button in a window:

```swift 
@main struct MyApp: App {
    @State var isMenuPresented: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Button("Show Menu") { isMenuPresented = true }
        }
        
        MenuBarExtra("MyApp Menu", systemImage: "folder") {
            Button("Menu Item 1") { print("Menu Item 1") }
            Button("Menu Item 2") { print("Menu Item 2") }
        }
        .menuBarExtraStyle(.menu)
        .menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in // <-- the magic ✨
             // access status item or store it in a @State var
        }
    }
}
```

### Window Style

An example of a button in the popup window dismissing the popup and performing an action:

```swift 
@main struct MyApp: App {
    @State var isMenuPresented: Bool = false
    
    var body: some Scene {
        MenuBarExtra("MyApp Menu", systemImage: "folder") {
            MyMenu(isMenuPresented: $isMenuPresented)
            	.introspectMenuBarExtraWindow { window in // <-- the magic ✨
                    window.animationBehavior = .alertPanel
                }
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in // <-- the magic ✨
             // access status item or store it in a @State var
        }
    }
}

struct MyMenu: View {
    @Binding var isMenuPresented: Bool

    var body: some View {
        Button("Perform Action") { 
            isMenuPresented = false 
            performSomeAction()
        }
    }
}
```

### Multiple MenuBarExtra

MenuBarExtraAccess is fully compatible with one or multiple MenuBarExtra in an app.

Just add an index number parameter to `.menuBarExtraAccess()` and `.introspectMenuBarExtraWindow()` that reflects the order of `MenuBarExtra` declarations.

```swift
var body: some Scene {
    MenuBarExtra("MyApp Menu A", systemImage: "folder") {
        MyMenu(isMenuPresented: $isMenuPresented)
            .introspectMenuBarExtraWindow(index: 0) { window in // <-- add index 0
                // ...
            }
    }
    .menuBarExtraStyle(.window)
    .menuBarExtraAccess(index: 0, isPresented: $isMenuPresented) // <-- add index 0
    
    MenuBarExtra("MyApp Menu B", systemImage: "folder") {
        MyMenu(isMenuPresented: $isMenuPresented)
            .introspectMenuBarExtraWindow(index: 1) { window in // <-- add index 1
                // ...
            }
    }
    .menuBarExtraStyle(.window)
    .menuBarExtraAccess(index: 1, isPresented: $isMenuPresented) // <-- add index 1
}
```

## Future

The hope is that Apple implements native versions of these features (and more) in future iterations of SwiftUI!

Until then, a radar has been filed as a feature request: [FB11984872](https://github.com/feedback-assistant/reports/issues/383)

## Menu Builder

Check out [MacControlCenterUI](https://github.com/orchetect/MacControlCenterUI), a SwiftUI package built on MenuBarExtraAccess for easily building Control Center style menus.

## Known Issues

- When using `.menuBarExtraStyle(.menu)`, SwiftUI causes the popup menu to block the runloop while the menu is open, which means:
  - Observing the `isPresented` binding will not work as expected.
  - Setting the `isPresented` binding to `false` while the menu is presented has no effect.
  - The user must dismiss the menu themself to allow event flow to continue. We have no control over this until Apple decides to change the MenuBarExtra behavior.

- There are edge cases where the status item gets confused and may invert its state. It may be related to how the underlying `MenuBarExtra` works. This is being investigated and a workaround may be possible for a future release.

## Author

Coded by a bunch of 🐹 hamsters in a trenchcoat that calls itself [@orchetect](https://github.com/orchetect).

## License

Licensed under the MIT license. See [LICENSE](https://github.com/orchetect/MenuBarExtraAccess/blob/master/LICENSE) for details.

## Sponsoring

If you enjoy using MenuBarExtraAccess and want to contribute to open-source financially, GitHub sponsorship is much appreciated. Feedback and code contributions are also welcome.

## Contributions

Contributions are welcome. Posting in [Discussions](https://github.com/orchetect/MenuBarExtraAccess/discussions) first prior to new submitting PRs for features or modifications is encouraged.
