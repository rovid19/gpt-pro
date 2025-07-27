import Cocoa

class SavedChatsView: NSView {
    private let container = NSStackView()
    private let headingStack = NSStackView()
    private let iconView = NSImageView()
    private let headingLabel = NSTextField(labelWithString: "Saved ")
    private let headingLabelGray = NSTextField(labelWithString: "Chats")
    private let menuButton = NSButton()
    private let menuIcon = NSImageView()
    private let dropdownMenu = NSView()
    private let deleteAllButton = NSButton()
    private let chatList = NSStackView()
    private var chatRowButtons: [NSButton] = []
    private var deleteButtons: [NSButton] = []
    private var dropdownVisible = false
    
    struct ChatRowData {
        let avatarURL: String
        let name: String
        let message: String
        let time: String
    }
    let chats: [ChatRowData] = [
        ChatRowData(avatarURL: "https://images.unsplash.com/photo-1621619856624-42fd193a0661?w=1080&q=80", name: "Ava Williams", message: "Let's lock in the final mock-ups tomorrow…", time: "2h"),
        ChatRowData(avatarURL: "https://images.unsplash.com/photo-1642615835477-d303d7dc9ee9?w=1080&q=80", name: "Marcus Chen", message: "Here's the build with the latest fixes.", time: "Yesterday"),
        ChatRowData(avatarURL: "https://images.unsplash.com/photo-1635151227785-429f420c6b9d?w=1080&q=80", name: "Sophia Patel", message: "Can we hop on a quick call in 10?", time: "Tue"),
        ChatRowData(avatarURL: "https://images.unsplash.com/photo-1621619856624-42fd193a0661?w=1080&q=80", name: "Lucas Martin", message: "Great work on the release, team!", time: "Mon")
    ]
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 1).cgColor
        layer?.cornerRadius = 16
        
        // Add padding view
        let paddingView = NSView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(paddingView)
        NSLayoutConstraint.activate([
            paddingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            paddingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            paddingView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            paddingView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        container.orientation = .vertical
        container.spacing = 0
        container.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        container.translatesAutoresizingMaskIntoConstraints = false
        paddingView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            container.topAnchor.constraint(equalTo: paddingView.topAnchor),
            container.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor)
        ])
        // Heading + actions
        headingStack.orientation = .horizontal
        headingStack.spacing = 8
        headingStack.alignment = .centerY
        // Archive icon
        if let archiveImage = NSImage(systemSymbolName: "archivebox", accessibilityDescription: nil) {
            iconView.image = archiveImage
            iconView.symbolConfiguration = .init(pointSize: 18, weight: .regular)
            iconView.contentTintColor = NSColor(calibratedWhite: 0.7, alpha: 1)
        }
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        headingStack.addArrangedSubview(iconView)
        // Heading label
        let attributedString = NSMutableAttributedString()
        let savedAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let chatsAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .regular), 
            .foregroundColor: NSColor(calibratedWhite: 0.7, alpha: 1)
        ]
        attributedString.append(NSAttributedString(string: "Saved ", attributes: savedAttributes))
        attributedString.append(NSAttributedString(string: "Chats", attributes: chatsAttributes))
        
        headingLabel.attributedStringValue = attributedString
        headingLabel.backgroundColor = .clear
        headingLabel.isBezeled = false
        headingLabel.isEditable = false
        headingLabel.drawsBackground = false
        headingStack.addArrangedSubview(headingLabel)
        // Spacer
        let headingSpacer = NSView()
        headingStack.addArrangedSubview(headingSpacer)
        // Menu button (three dots)
        let hoverMenuButton = HoverButton()
        hoverMenuButton.title = ""
        hoverMenuButton.isBordered = false
        hoverMenuButton.wantsLayer = true
        hoverMenuButton.layer?.backgroundColor = .clear
        hoverMenuButton.setButtonType(.momentaryChange)
        hoverMenuButton.target = self
        hoverMenuButton.action = #selector(toggleDropdown)
        hoverMenuButton.translatesAutoresizingMaskIntoConstraints = false
        menuIcon.translatesAutoresizingMaskIntoConstraints = false
        if let moreIcon = NSImage(systemSymbolName: "ellipsis", accessibilityDescription: nil) {
            menuIcon.image = moreIcon
            menuIcon.symbolConfiguration = .init(pointSize: 18, weight: .regular)
            menuIcon.contentTintColor = NSColor(calibratedWhite: 0.6, alpha: 1)
        }
        hoverMenuButton.addSubview(menuIcon)
        NSLayoutConstraint.activate([
            menuIcon.centerXAnchor.constraint(equalTo: hoverMenuButton.centerXAnchor),
            menuIcon.centerYAnchor.constraint(equalTo: hoverMenuButton.centerYAnchor),
            hoverMenuButton.widthAnchor.constraint(equalToConstant: 28),
            hoverMenuButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        hoverMenuButton.onHoverChanged = { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        headingStack.addArrangedSubview(hoverMenuButton)
        container.addArrangedSubview(headingStack)
        container.setCustomSpacing(24, after: headingStack)
        // Dropdown menu
        dropdownMenu.wantsLayer = true
        dropdownMenu.layer?.backgroundColor = NSColor(calibratedWhite: 0.12, alpha: 1).cgColor
        dropdownMenu.layer?.cornerRadius = 8
        dropdownMenu.layer?.borderWidth = 1
        dropdownMenu.layer?.borderColor = NSColor(calibratedWhite: 0.2, alpha: 0.5).cgColor
        dropdownMenu.isHidden = true
        dropdownMenu.translatesAutoresizingMaskIntoConstraints = false
        dropdownMenu.layer?.zPosition = 100
        // Delete All button
        deleteAllButton.title = "Delete All"
        deleteAllButton.isBordered = false
        deleteAllButton.font = NSFont.systemFont(ofSize: 14)
        deleteAllButton.contentTintColor = NSColor.systemRed
        deleteAllButton.alignment = .left
        deleteAllButton.target = self
        deleteAllButton.action = #selector(handleDeleteAll)
        deleteAllButton.wantsLayer = true
        deleteAllButton.layer?.backgroundColor = .clear
        // Trash icon for delete all
        let trashIcon = NSImageView()
        if let trashImage = NSImage(systemSymbolName: "trash", accessibilityDescription: nil) {
            trashIcon.image = trashImage
            trashIcon.symbolConfiguration = .init(pointSize: 14, weight: .regular)
            trashIcon.contentTintColor = NSColor.systemRed
        }
        trashIcon.translatesAutoresizingMaskIntoConstraints = false
        let deleteAllStack = NSStackView(views: [trashIcon, deleteAllButton])
        deleteAllStack.orientation = .horizontal
        deleteAllStack.spacing = 8
        deleteAllStack.edgeInsets = NSEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        dropdownMenu.addSubview(deleteAllStack)
        NSLayoutConstraint.activate([
            deleteAllStack.leadingAnchor.constraint(equalTo: dropdownMenu.leadingAnchor),
            deleteAllStack.trailingAnchor.constraint(equalTo: dropdownMenu.trailingAnchor),
            deleteAllStack.topAnchor.constraint(equalTo: dropdownMenu.topAnchor),
            deleteAllStack.bottomAnchor.constraint(equalTo: dropdownMenu.bottomAnchor),
            dropdownMenu.widthAnchor.constraint(equalToConstant: 140),
            dropdownMenu.heightAnchor.constraint(equalToConstant: 36)
        ])
        addSubview(dropdownMenu)
        NSLayoutConstraint.activate([
            dropdownMenu.topAnchor.constraint(equalTo: hoverMenuButton.bottomAnchor, constant: 6),
            dropdownMenu.trailingAnchor.constraint(equalTo: hoverMenuButton.trailingAnchor)
        ])
        // Chat list
        chatList.orientation = .vertical
        chatList.spacing = 12
        for (i, chat) in chats.enumerated() {
            let row = makeChatRow(chat: chat, index: i)
            chatList.addArrangedSubview(row)
            chatRowButtons.append(row)
        }
        container.addArrangedSubview(chatList)
        // Dismiss dropdown on click outside
        let clickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self = self else { return event }
            if self.dropdownVisible, !self.dropdownMenu.frame.contains(self.convert(event.locationInWindow, from: nil)) {
                self.hideDropdown()
            }
            return event
        }
        // Store monitor to remove if needed
        objc_setAssociatedObject(self, "SavedChatsViewClickMonitor", clickMonitor, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeChatRow(chat: ChatRowData, index: Int) -> NSButton {
        let button = HoverButton()
        button.title = ""
        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor(calibratedWhite: 0.12, alpha: 1).cgColor
        button.layer?.cornerRadius = 12
        button.layer?.borderWidth = 1
        button.layer?.borderColor = NSColor(calibratedWhite: 0.2, alpha: 0.5).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        // Row stack
        let rowStack = NSStackView()
        rowStack.orientation = .horizontal
        rowStack.spacing = 16
        rowStack.alignment = .centerY
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        // Avatar
        let avatar = NSImageView()
        avatar.wantsLayer = true
        avatar.layer?.cornerRadius = 24
        avatar.layer?.masksToBounds = true
        avatar.imageScaling = .scaleAxesIndependently
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.widthAnchor.constraint(equalToConstant: 48).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 48).isActive = true
        if let url = URL(string: chat.avatarURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = NSImage(data: data) {
                    DispatchQueue.main.async {
                        avatar.image = img
                    }
                }
            }
        }
        rowStack.addArrangedSubview(avatar)
        // Name & message
        let textStack = NSStackView()
        textStack.orientation = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        let nameLabel = NSTextField(labelWithString: chat.name)
        nameLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = NSColor.white
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.maximumNumberOfLines = 1
        let messageLabel = NSTextField(labelWithString: chat.message)
        messageLabel.font = NSFont.systemFont(ofSize: 13)
        messageLabel.textColor = NSColor(calibratedWhite: 0.7, alpha: 1)
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.maximumNumberOfLines = 1
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(messageLabel)
        rowStack.addArrangedSubview(textStack)
        // Spacer
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rowStack.addArrangedSubview(spacer)
        // Time
        let timeLabel = NSTextField(labelWithString: chat.time)
        timeLabel.font = NSFont.systemFont(ofSize: 12)
        timeLabel.textColor = NSColor(calibratedWhite: 0.6, alpha: 1)
        timeLabel.alignment = .right
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        rowStack.addArrangedSubview(timeLabel)
        // Delete button
        let deleteButton = HoverButton()
        deleteButton.title = ""
        deleteButton.isBordered = false
        deleteButton.wantsLayer = true
        deleteButton.layer?.backgroundColor = .clear
        deleteButton.setButtonType(.momentaryChange)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        if let trashImage = NSImage(systemSymbolName: "trash", accessibilityDescription: nil) {
            let trashIcon = NSImageView(image: trashImage)
            trashIcon.symbolConfiguration = .init(pointSize: 16, weight: .regular)
            trashIcon.contentTintColor = NSColor(calibratedWhite: 0.6, alpha: 1)
            trashIcon.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.addSubview(trashIcon)
            NSLayoutConstraint.activate([
                trashIcon.centerXAnchor.constraint(equalTo: deleteButton.centerXAnchor),
                trashIcon.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
                deleteButton.widthAnchor.constraint(equalToConstant: 28),
                deleteButton.heightAnchor.constraint(equalToConstant: 28)
            ])
        }
        deleteButton.action = #selector(handleDeleteChat(_:))
        deleteButton.target = self
        deleteButton.tag = index
        deleteButtons.append(deleteButton)
        rowStack.addArrangedSubview(deleteButton)
        button.addSubview(rowStack)
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 12),
            rowStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            rowStack.topAnchor.constraint(equalTo: button.topAnchor, constant: 8),
            rowStack.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -8)
        ])
        // Hover effect for row
        button.onHoverChanged = { [weak button] hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
            button?.layer?.backgroundColor = hovering ? NSColor(calibratedWhite: 0.16, alpha: 1).cgColor : NSColor(calibratedWhite: 0.12, alpha: 1).cgColor
        }
        // Hover effect for delete button
        deleteButton.onHoverChanged = { [weak deleteButton] hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
            deleteButton?.subviews.compactMap { $0 as? NSImageView }.first?.contentTintColor = hovering ? NSColor.systemRed : NSColor(calibratedWhite: 0.6, alpha: 1)
        }
        return button
    }
    
    @objc private func toggleDropdown() {
        dropdownVisible.toggle()
        dropdownMenu.isHidden = !dropdownVisible
    }
    private func hideDropdown() {
        dropdownVisible = false
        dropdownMenu.isHidden = true
    }
    @objc private func handleDeleteAll() {
        // TODO: Implement delete all logic
        hideDropdown()
    }
    @objc private func handleDeleteChat(_ sender: NSButton) {
        // TODO: Implement delete chat logic for sender.tag
    }
    
    func addChatToTop(_ chat: ChatRowData) {
        let newRow = makeChatRow(chat: chat, index: 0)
        
        // Insert at the beginning of the chat list
        chatList.insertArrangedSubview(newRow, at: 0)
        chatRowButtons.insert(newRow, at: 0)
        
        // Update indices for existing delete buttons
        for (index, button) in deleteButtons.enumerated() {
            button.tag = index + 1
        }
        deleteButtons.insert(newRow.subviews.compactMap { $0 as? HoverButton }.first ?? HoverButton(), at: 0)
        
        NSLog("[gptapp] Added new chat to top: \(chat.name)")
    }
}

// HoverButton: NSButton subclass with hover tracking
class HoverButton: NSButton {
    var onHoverChanged: ((Bool) -> Void)?
    private var trackingArea: NSTrackingArea?
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect]
        trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    override func mouseEntered(with event: NSEvent) {
        onHoverChanged?(true)
    }
    override func mouseExited(with event: NSEvent) {
        onHoverChanged?(false)
    }
}
