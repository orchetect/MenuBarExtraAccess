# MenuBarExtraAccess

**Gives you *Extra* access to `MenuBarExtra`.**

A convenient set of bindings and methods to add state management to Apple's `MenuBarExtra` SwiftUI Scene introduced in macOS 13.0 Ventura.

As of macOS Ventura 13.2 / Xcode 14.2 there is no 1st-party API to:
- Programmatically hide or show a menu bar extra's menu (using `.menuBarExtraStyle(.menu)`) 
- Programmatically hide or show a menu bar extra's window (using `.menuBarExtraStyle(.window)`)

This library seeks to add that missing functionality by exposing a new `.menuBarExtraAccess(isPresented:)` view modifier with a binding.

```swift
import SwiftUI
import MenuBarExtraAccess
```

With standard menu style (`.menuBarExtraStyle(.menu)`):

```swift 
@main
struct MyApp: App {
    @State var isMenuPresented: Bool = false
    
    var body: some Scene {
        MenuBarExtra("MyApp Menu", systemImage: "folder.fill") {
            Button("Menu Item 1") { print("Menu Item 1") }
            Button("Menu Item 2") { print("Menu Item 2") }
        }
        .menuBarExtraStyle(.menu)
        .menuBarExtraAccess(isPresented: $isMenuPresented)
        
        WindowGroup {
            Button("Show Menu") { isMenuPresented = true }
        }
    }
}
```

With window style (`.menuBarExtraStyle(.window)`):

```swift 
@main
struct MyApp: App {
    @State var isMenuPresented: Bool = false
    
    var body: some Scene {
        MenuBarExtra("MyApp Menu", systemImage: "folder.fill") {
            Button("Menu Item 1") { print("Menu Item 1") }
            Button("Menu Item 2") { print("Menu Item 2") }
            Button("Close Menu") { isMenuPresented = false }
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented)
    }
}
```

## Future

The hope is that Apple implements this feature (and more) in future iterations of SwiftUI!

Until then, a radar has been filed: [FB11984872](https://github.com/feedback-assistant/reports/issues/383)

## To Do

- [ ] `isPresented` binding is not updated when the user opens or closes the menu bar extra's menu/window
  - Add KVO observers to the NSStatusItem and/or its NSWindow?
- [ ] When using `.menuBarExtraStyle(.menu)`, the popup menu blocks the runloop so setting the isPresented binding to false has no real effect.
