import Foundation

class ChromeExtensionBridge {
    private let stdin = FileHandle.standardInput
    private let stdout = FileHandle.standardOutput
    private let stderr = FileHandle.standardError
    
    func start() {
        NSLog("[gptapp] Native messaging host started")
        
        // Send initial connection message
        sendMessage(["type": "connected", "message": "Native host ready"])
        
        while true {
            guard let message = readMessage() else { break }
            
            NSLog("[gptapp] Received message: \(message)")
            
            // Handle different message types
            if let action = message["action"] as? String {
                switch action {
                case "ping":
                    sendMessage(["type": "pong", "timestamp": Date().timeIntervalSince1970])
                case "openChatGPT":
                    // Trigger your Mac app's shortcut functionality here
                    handleOpenChatGPT()
                    sendMessage(["type": "response", "action": "openChatGPT", "status": "triggered"])
                default:
                    NSLog("[gptapp] Unknown action: \(action)")
                }
            }
        }
    }
    
    private func handleOpenChatGPT() {
        NSLog("[gptapp] Opening ChatGPT via Chrome extension")
        // This is where you'd trigger your Mac app's shortcut functionality
        // For example, you could post a notification or call a method
        NotificationCenter.default.post(name: .openChatGPT, object: nil)
    }
    
    private func sendMessage(_ message: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message)
            let length = UInt32(jsonData.count)
            
            // Write 4-byte length prefix
            var lengthBytes = withUnsafeBytes(of: length.littleEndian) { Data($0) }
            stdout.write(lengthBytes)
            
            // Write JSON message
            stdout.write(jsonData)

            NSLog("[gptapp] Sent message: \(message)")
        } catch {
            NSLog("[gptapp] Error sending message: \(error)")
        }
    }
    
    private func readMessage() -> [String: Any]? {
        // Read 4-byte length prefix
        let lengthData = stdin.readData(ofLength: 4)
        guard lengthData.count == 4 else { return nil }
        
        let length = lengthData.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
        
        // Read JSON message
        let messageData = stdin.readData(ofLength: Int(length))
        guard !messageData.isEmpty else { return nil }
        
        do {
            let message = try JSONSerialization.jsonObject(with: messageData) as? [String: Any]
            return message
        } catch {
            NSLog("[gptapp] Error parsing message: \(error)")
            return nil
        }
    }
}

// Extension for notification name
extension Notification.Name {
    static let openChatGPT = Notification.Name("openChatGPT")
}

// Main entry point
/*if CommandLine.arguments.contains("--native-messaging") {
    let host = ChromeExtensionBridge()
    host.start()
} */