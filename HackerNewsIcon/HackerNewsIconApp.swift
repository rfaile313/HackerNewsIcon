import SwiftUI

@main
struct HackerNewsIconApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Keep App lifecycle running without opening a window.
        Settings {}
    }
}
