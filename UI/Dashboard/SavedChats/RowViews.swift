import Cocoa

// MARK: - Row View Factory

class RowViewFactory {
    static func makeChatRow(chat: ChatRowData, index _: Int) -> NSButton {
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
                deleteButton.widthAnchor.constraint(equalToConstant: 32),
                deleteButton.heightAnchor.constraint(equalToConstant: 32),
            ])
        }
        deleteButton.target = nil // Will be set by parent
        deleteButton.action = nil // Will be set by parent
        deleteButton.onHoverChanged = { hovering in
            if let trashIcon = deleteButton.subviews.compactMap({ $0 as? NSImageView }).first {
                trashIcon.contentTintColor = hovering ? NSColor.systemRed : NSColor(calibratedWhite: 0.6, alpha: 1)
            }
        }
        rowStack.addArrangedSubview(deleteButton)
        button.addSubview(rowStack)
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            rowStack.topAnchor.constraint(equalTo: button.topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: button.bottomAnchor),
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

    static func makeFolderRow(folderName: String, index: Int) -> NSButton {
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
        button.tag = index

        // Row stack
        let rowStack = NSStackView()
        rowStack.orientation = .horizontal
        rowStack.spacing = 16
        rowStack.alignment = .centerY
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        // Folder icon
        let folderIcon = NSImageView()
        folderIcon.wantsLayer = true
        folderIcon.layer?.cornerRadius = 24
        folderIcon.layer?.masksToBounds = true
        folderIcon.translatesAutoresizingMaskIntoConstraints = false
        folderIcon.widthAnchor.constraint(equalToConstant: 48).isActive = true
        folderIcon.heightAnchor.constraint(equalToConstant: 48).isActive = true

        if let folderImage = NSImage(systemSymbolName: "folder", accessibilityDescription: nil) {
            folderIcon.image = folderImage
            folderIcon.symbolConfiguration = .init(pointSize: 24, weight: .regular)
            folderIcon.contentTintColor = NSColor.systemBlue
        }

        rowStack.addArrangedSubview(folderIcon)

                // Folder name
        let nameLabel = NSTextField(labelWithString: folderName)
        nameLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = NSColor.white
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.maximumNumberOfLines = 1
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        rowStack.addArrangedSubview(nameLabel)

        // Spacer
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rowStack.addArrangedSubview(spacer)

        // Three dots menu button
        let menuButton = HoverButton()
        menuButton.title = ""
        menuButton.isBordered = false
        menuButton.wantsLayer = true
        menuButton.layer?.backgroundColor = .clear
        menuButton.setButtonType(.momentaryChange)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.tag = index

        if let moreIcon = NSImage(systemSymbolName: "ellipsis", accessibilityDescription: nil) {
            let menuIcon = NSImageView(image: moreIcon)
            menuIcon.symbolConfiguration = .init(pointSize: 16, weight: .regular)
            menuIcon.contentTintColor = NSColor(calibratedWhite: 0.6, alpha: 1)
            menuIcon.translatesAutoresizingMaskIntoConstraints = false
            menuButton.addSubview(menuIcon)
            NSLayoutConstraint.activate([
                menuIcon.centerXAnchor.constraint(equalTo: menuButton.centerXAnchor),
                menuIcon.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor),
                menuButton.widthAnchor.constraint(equalToConstant: 32),
                menuButton.heightAnchor.constraint(equalToConstant: 32),
            ])
        }

        menuButton.target = nil // Will be set by parent
        menuButton.action = nil // Will be set by parent
        menuButton.onHoverChanged = { hovering in
            if let menuIcon = menuButton.subviews.compactMap({ $0 as? NSImageView }).first {
                menuIcon.contentTintColor = hovering ? NSColor.systemBlue : NSColor(calibratedWhite: 0.6, alpha: 1)
            }
        }
        rowStack.addArrangedSubview(menuButton)
        button.addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            rowStack.topAnchor.constraint(equalTo: button.topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: button.bottomAnchor),
        ])

        // Set content hugging priority to prevent the button from shrinking
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Hover effect for row
        button.onHoverChanged = { [weak button] hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
            button?.layer?.backgroundColor = hovering ? NSColor(calibratedWhite: 0.16, alpha: 1).cgColor : NSColor(calibratedWhite: 0.12, alpha: 1).cgColor
        }

        return button
    }

    static func makeEditableFolderRow(index: Int, delegate: NSTextFieldDelegate) -> NSButton {
        let button = HoverButton()
        button.title = ""
        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor(calibratedWhite: 0.12, alpha: 1).cgColor
        button.layer?.cornerRadius = 12
        button.layer?.borderWidth = 1
        button.layer?.borderColor = NSColor.systemBlue.cgColor // Highlight with blue border
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        button.tag = index

        // Row stack
        let rowStack = NSStackView()
        rowStack.orientation = .horizontal
        rowStack.spacing = 16
        rowStack.alignment = .centerY
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        // Folder icon
        let folderIcon = NSImageView()
        folderIcon.wantsLayer = true
        folderIcon.layer?.cornerRadius = 24
        folderIcon.layer?.masksToBounds = true
        folderIcon.translatesAutoresizingMaskIntoConstraints = false
        folderIcon.widthAnchor.constraint(equalToConstant: 48).isActive = true
        folderIcon.heightAnchor.constraint(equalToConstant: 48).isActive = true

        if let folderImage = NSImage(systemSymbolName: "folder", accessibilityDescription: nil) {
            folderIcon.image = folderImage
            folderIcon.symbolConfiguration = .init(pointSize: 24, weight: .regular)
            folderIcon.contentTintColor = NSColor.systemBlue
        }

        rowStack.addArrangedSubview(folderIcon)

        // Editable folder name text field
        let nameTextField = NSTextField()
        nameTextField.stringValue = "New Folder"
        nameTextField.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        nameTextField.textColor = NSColor.white
        nameTextField.backgroundColor = NSColor.clear
        nameTextField.isBordered = false
        nameTextField.focusRingType = .none
        nameTextField.isEditable = true
        nameTextField.isSelectable = true
        nameTextField.drawsBackground = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false

        // Set up text field delegate
        nameTextField.delegate = delegate

        NSLog("[gptapp] 📝 Created text field with initial value: '\(nameTextField.stringValue)'")

        rowStack.addArrangedSubview(nameTextField)

        // Spacer
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rowStack.addArrangedSubview(spacer)

        // Delete button
        let deleteButton = HoverButton()
        deleteButton.title = ""
        deleteButton.isBordered = false
        deleteButton.wantsLayer = true
        deleteButton.layer?.backgroundColor = .clear
        deleteButton.setButtonType(.momentaryChange)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.tag = index

        if let trashImage = NSImage(systemSymbolName: "trash", accessibilityDescription: nil) {
            let trashIcon = NSImageView(image: trashImage)
            trashIcon.symbolConfiguration = .init(pointSize: 16, weight: .regular)
            trashIcon.contentTintColor = NSColor(calibratedWhite: 0.6, alpha: 1)
            trashIcon.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.addSubview(trashIcon)
            NSLayoutConstraint.activate([
                trashIcon.centerXAnchor.constraint(equalTo: deleteButton.centerXAnchor),
                trashIcon.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
                deleteButton.widthAnchor.constraint(equalToConstant: 32),
                deleteButton.heightAnchor.constraint(equalToConstant: 32),
            ])
        }

        deleteButton.target = nil // Will be set by parent
        deleteButton.action = nil // Will be set by parent
        deleteButton.onHoverChanged = { hovering in
            if let trashIcon = deleteButton.subviews.compactMap({ $0 as? NSImageView }).first {
                trashIcon.contentTintColor = hovering ? NSColor.systemRed : NSColor(calibratedWhite: 0.6, alpha: 1)
            }
        }

        rowStack.addArrangedSubview(deleteButton)
        button.addSubview(rowStack)

        // Set up constraints for the row stack
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            rowStack.topAnchor.constraint(equalTo: button.topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: button.bottomAnchor),
        ])

        // Set content hugging priority to prevent the button from shrinking
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    

        // Focus the text field after a longer delay to ensure it's properly set up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NSLog("[gptapp] 🎯 Focusing text field")
            NSLog("[gptapp] 📝 Text field properties - Editable: \(nameTextField.isEditable), Selectable: \(nameTextField.isSelectable)")

            nameTextField.becomeFirstResponder()
            nameTextField.selectText(nil)

            NSLog("[gptapp] ✅ Text field focused and ready for input")
        }

        return button
    }
}
