import SwiftUI

struct ContentView: View {
    @EnvironmentObject var chatManager: ChatManager
    
    var body: some View {
        FloatingIconView()
            .environmentObject(chatManager)
            .frame(width: 0, height: 0)
            .background(Color.clear)
    }
}