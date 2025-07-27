import Foundation

class WebSocketBridge {
    private var isRunning = true
    private let queue = DispatchQueue(label: "WebSocketBridgeQueue")
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://localhost:3000")!
    private var savedChatsController: SavedChatsController?

    init() {
        connect()
    }
    
    func setSavedChatsController(_ controller: SavedChatsController) {
        self.savedChatsController = controller
    }

    private func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        NSLog("[gptapp] WebSocket connecting to: \(url)")
        
        // Send identify message
        let identifyMessage: [String: Any] = [
            "type": "identify",
            "payload": ["role": "native-app"]
        ]
        sendMessage(identifyMessage)
        
        listen()
    }

    private func listen() {
        guard isRunning else { return }
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                NSLog("[gptapp] WebSocket receive error: %@", String(describing: error))
                // Try to reconnect on error
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.connect()
                }
            case .success(let message):
                switch message {
                case .data(let data):
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        NSLog("[gptapp] Received from WS: %@", String(describing: json))
                        // Optionally, handle the message or send a response
                    }
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        NSLog("[gptapp] Received from WS: %@", String(describing: json))
                        self.handleWebSocketMessage(json)
                    }
                @unknown default:
                    break
                }
            }
            // Continue listening
            self.listen()
        }
    }

    func sendMessage(_ message: [String: Any]) {
        guard let webSocketTask = webSocketTask else { return }
        guard let data = try? JSONSerialization.data(withJSONObject: message, options: []) else { return }
        let text = String(data: data, encoding: .utf8) ?? ""
        webSocketTask.send(.string(text)) { error in
            if let error = error {
                NSLog("[gptapp] WebSocket send error: %@", String(describing: error))
            }
        }
    }

    func stop() {
        isRunning = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func handleWebSocketMessage(_ json: [String: Any]) {
        guard let type = json["type"] as? String else { 
            NSLog("[gptapp] Message missing type field")
            return 
        }
        
        guard let payload = json["payload"] as? [String: Any] else {
            NSLog("[gptapp] Message missing payload field")
            return
        }
        
        switch type {
        case "save-chat-response":
            NSLog("[gptapp] Received save-chat-response message")
            if let success = payload["success"] as? Bool,
               let chatHref = payload["chatHref"] as? String,
               let chatTitle = payload["chatTitle"] as? String,
               let timestamp = payload["timestamp"] as? String {
                NSLog("[gptapp] Received save-chat-response: success=\(success), title=\(chatTitle), href=\(chatHref)")
                if success {
                    savedChatsController?.injectNewChat(title: chatTitle, link: chatHref)
                }
            }
        case "new-message":
            // Handle new message
            NSLog("[gptapp] Received new-message")
            // Add your new message handling logic here
            
        case "user-status":
            // Handle user status update
            NSLog("[gptapp] Received user-status")
            // Add your user status handling logic here
            
        case "notification":
            // Handle notification
            NSLog("[gptapp] Received notification")
            // Add your notification handling logic here
            
        default:
            NSLog("[gptapp] Unknown message type: \(type)")
        }
    }
}
