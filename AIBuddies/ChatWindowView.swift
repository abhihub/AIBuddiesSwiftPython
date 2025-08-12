import SwiftUI

struct ChatWindowView: View {
    @EnvironmentObject var chatManager: ChatManager
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            chatMessagesView
            
            inputView
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            chatManager.clearNotifications()
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "pawprint.fill")
                .foregroundColor(.white)
                .font(.system(size: 16))
            
            Text("Leo Pet")
                .font(.headline)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: { chatManager.clearConversation() }) {
                Image(systemName: "trash")
                    .foregroundColor(.white.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.black.opacity(0.2))
    }
    
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if chatManager.messages.isEmpty {
                        welcomeMessage
                    } else {
                        ForEach(chatManager.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: chatManager.messages.count) { _ in
                withAnimation {
                    if let lastMessage = chatManager.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var welcomeMessage: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("🐕")
                .font(.system(size: 48))
            
            Text("Hello! I'm Leo Pet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Your friendly AI assistant. How can I help you today?")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
    
    private var inputView: some View {
        HStack {
            TextField("Type your message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color.black.opacity(0.1))
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        chatManager.sendMessage(text)
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                userMessageBubble
            } else {
                assistantMessageBubble
                Spacer()
            }
        }
    }
    
    private var userMessageBubble: some View {
        Text(message.content)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.9))
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: 250, alignment: .trailing)
    }
    
    private var assistantMessageBubble: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("🐕")
                .font(.system(size: 20))
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                if message.isLoading {
                    HStack {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 6, height: 6)
                                .scaleEffect(message.isLoading ? 1.0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: message.isLoading
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
        }
        .frame(maxWidth: 250, alignment: .leading)
    }
}