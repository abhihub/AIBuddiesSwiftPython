import SwiftUI
import AppKit

struct FloatingIconView: NSViewRepresentable {
    @EnvironmentObject var chatManager: ChatManager
    
    func makeNSView(context: Context) -> FloatingIconNSView {
        let view = FloatingIconNSView()
        view.chatManager = chatManager
        return view
    }
    
    func updateNSView(_ nsView: FloatingIconNSView, context: Context) {
        nsView.updateNotificationState(hasNotification: chatManager.hasNewMessage)
    }
}

class FloatingIconNSView: NSView {
    var chatManager: ChatManager?
    private var floatingWindow: NSWindow?
    private var hasNotification = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupFloatingIcon()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupFloatingIcon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFloatingIcon()
    }
    
    private func setupFloatingIcon() {
        DispatchQueue.main.async { [weak self] in
            self?.createFloatingWindow()
        }
    }
    
    private func createFloatingWindow() {
        guard let screen = NSScreen.main else { return }
        
        let iconSize: CGFloat = 80
        let padding: CGFloat = 20
        
        let windowFrame = NSRect(
            x: screen.frame.width - iconSize - padding,
            y: padding,
            width: iconSize,
            height: iconSize
        )
        
        floatingWindow = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        floatingWindow?.level = .floating
        floatingWindow?.isOpaque = false
        floatingWindow?.backgroundColor = NSColor.clear
        floatingWindow?.hasShadow = true
        floatingWindow?.ignoresMouseEvents = false
        
        let iconView = FloatingIconContentView(hasNotification: hasNotification) { [weak self] in
            self?.iconClicked()
        }
        
        let hostingView = NSHostingView(rootView: iconView)
        hostingView.frame = NSRect(x: 0, y: 0, width: iconSize, height: iconSize)
        
        floatingWindow?.contentView = hostingView
        floatingWindow?.makeKeyAndOrderFront(nil)
        floatingWindow?.orderFrontRegardless()
    }
    
    private func iconClicked() {
        print("🐕 Icon clicked!")
        chatManager?.openChatWindow()
        chatManager?.clearNotifications()
    }
    
    func updateNotificationState(hasNotification: Bool) {
        self.hasNotification = hasNotification
        
        // Recreate the content view with updated state
        let iconView = FloatingIconContentView(hasNotification: hasNotification) { [weak self] in
            self?.iconClicked()
        }
        
        if let window = floatingWindow {
            let hostingView = NSHostingView(rootView: iconView)
            hostingView.frame = NSRect(x: 0, y: 0, width: 80, height: 80)
            window.contentView = hostingView
        }
    }
}

struct FloatingIconContentView: View {
    let hasNotification: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            
            Text("🐕")
                .font(.system(size: 28))
            
            if hasNotification {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                            )
                    }
                    Spacer()
                }
                .frame(width: 60, height: 60)
            }
        }
        .onTapGesture {
            onTap()
        }
        .cursor(.pointingHand)
    }
}

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}