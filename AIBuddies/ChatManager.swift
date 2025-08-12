import Foundation
import SwiftUI
import AppKit

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    var isLoading: Bool
    
    init(content: String, isUser: Bool, isLoading: Bool = false) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.isLoading = isLoading
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.content = try container.decode(String.self, forKey: .content)
        self.isUser = try container.decode(Bool.self, forKey: .isUser)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.isLoading = try container.decodeIfPresent(Bool.self, forKey: .isLoading) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(isUser, forKey: .isUser)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(isLoading, forKey: .isLoading)
    }
    
    private enum CodingKeys: String, CodingKey {
        case content, isUser, timestamp, isLoading
    }
}

class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var hasNewMessage: Bool = false
    @Published var isLoading: Bool = false
    @Published var apiKey: String = ""
    
    private var chatWindowController: NSWindowController?
    
    init() {
        loadAPIKey()
    }
    
    private func loadAPIKey() {
        if let key = UserDefaults.standard.string(forKey: "OpenAIAPIKey") {
            self.apiKey = key
        }
    }
    
    func saveAPIKey(_ key: String) {
        self.apiKey = key
        UserDefaults.standard.set(key, forKey: "OpenAIAPIKey")
    }
    
    func sendMessage(_ text: String) {
        if apiKey.isEmpty {
            showAPIKeyAlert()
            return
        }
        
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)
        
        let loadingMessage = ChatMessage(content: "", isUser: false, isLoading: true)
        messages.append(loadingMessage)
        
        isLoading = true
        
        callPythonBackend(message: text) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let lastIndex = self?.messages.lastIndex(where: { $0.isLoading }) {
                    self?.messages.remove(at: lastIndex)
                }
                
                let aiMessage = ChatMessage(content: response, isUser: false)
                self?.messages.append(aiMessage)
                self?.hasNewMessage = true
            }
        }
    }
    
    private func callPythonBackend(message: String, completion: @escaping (String) -> Void) {
        guard let resourcePath = Bundle.main.resourcePath else {
            completion("Error: Could not find app resources")
            return
        }
        
        let pythonScriptPath = "\(resourcePath)/ai_backend.py"
        
        let task = Process()
        task.launchPath = "/usr/bin/python3"
        task.arguments = [pythonScriptPath, apiKey, message]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.terminationHandler = { _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                if let jsonData = output.data(using: .utf8),
                   let result = try? JSONDecoder().decode(AIResponse.self, from: jsonData) {
                    if result.success {
                        completion(result.response ?? "No response")
                    } else {
                        completion("Error: \(result.error ?? "Unknown error")")
                    }
                } else {
                    completion("Error: Could not parse response")
                }
            } else {
                completion("Error: No response from AI")
            }
        }
        
        task.launch()
    }
    
    private func showAPIKeyAlert() {
        let alert = NSAlert()
        alert.messageText = "OpenAI API Key Required"
        alert.informativeText = "Please enter your OpenAI API key to use AIBuddies."
        alert.alertStyle = .informational
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.stringValue = apiKey
        textField.placeholderString = "sk-..."
        alert.accessoryView = textField
        
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            let key = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !key.isEmpty {
                saveAPIKey(key)
            }
        }
    }
    
    func clearConversation() {
        messages.removeAll()
        hasNewMessage = false
    }
    
    func clearNotifications() {
        hasNewMessage = false
    }
    
    func openChatWindow() {
        print("🐕 Opening chat window...")
        DispatchQueue.main.async {
            // Always create a new chat window for now to ensure it works
            self.createNewChatWindow()
        }
    }
    
    private func createNewChatWindow() {
        let chatWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        chatWindow.title = "AIBuddies Chat"
        chatWindow.center()
        
        let chatView = ChatWindowView().environmentObject(self)
        chatWindow.contentView = NSHostingView(rootView: chatView)
        
        chatWindow.makeKeyAndOrderFront(nil)
        
        self.chatWindowController = NSWindowController(window: chatWindow)
    }
}

struct AIResponse: Codable {
    let success: Bool
    let response: String?
    let error: String?
}