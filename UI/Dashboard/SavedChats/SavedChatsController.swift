import Cocoa

class SavedChatsController {
    private weak var savedChatsView: SavedChatsView?
    
    init(savedChatsView: SavedChatsView) {
        self.savedChatsView = savedChatsView
    }
    
    func injectNewChat(title: String, link: String) {
        NSLog("[gptapp] Injecting new chat: \(title) with link: \(link)")
        
        // Create chat data
        let newChat = SavedChatsView.ChatRowData(
            avatarURL: "https://images.unsplash.com/photo-1621619856624-42fd193a0661?w=1080&q=80", // Default avatar
            name: title,
            message: "Chat saved from extension",
            time: "Now"
        )
        
        // Add to the beginning of the chat list
        savedChatsView?.addChatToTop(newChat)
    }
}
