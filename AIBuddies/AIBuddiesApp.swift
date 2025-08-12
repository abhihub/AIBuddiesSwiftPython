import SwiftUI

@main
struct AIBuddiesApp: App {
    @StateObject private var chatManager = ChatManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chatManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 100, height: 100)
    }
}