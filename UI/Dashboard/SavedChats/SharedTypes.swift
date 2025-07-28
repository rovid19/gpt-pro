import Foundation

// MARK: - Shared Data Structures
struct ChatRowData {
    let avatarURL: String
    let name: String
    let message: String
    let time: String
}

struct FolderRowData {
    let name: String
}

enum SavedItem {
    case chat(ChatRowData)
    case folder(FolderRowData)
} 