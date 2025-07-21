import Foundation
import AppKit

class XcodeMessageSender {
    private let bridgeInputPath = "/tmp/gptapp_messages.txt"
    
    func sendOpenChatGPTMessage() {
        NSLog("[gptapp] Sending openChatGPT message to Chrome extension")
        
        let response: [String: Any] = [
            "type": "response",
            "action": "openChatGPT",
            "status": "success",
            "message": "ChatGPT opened successfully"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            try jsonData.write(to: URL(fileURLWithPath: bridgeInputPath), options: .atomic)
            NSLog("[gptapp] ✅ Message written to bridge input: \(bridgeInputPath)")
        } catch {
            NSLog("[gptapp] ❌ Failed to write message to bridge: \(error)")
        }
    }
}
