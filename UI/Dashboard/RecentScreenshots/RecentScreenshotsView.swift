import Cocoa

class RecentScreenshotsView: NSView {
    let padding: CGFloat = 16
    
    private let container = NSStackView()
    private let headingStack = NSStackView()
    private let iconView = NSImageView()
    private let headingLabel = NSTextField(labelWithString: "")
    private let contentWrapper = NSView()
    private let noScreenshotLabel = NSTextField(labelWithString: "No screenshot available")
    
    private var currentDraggableImageView: DraggableImageView?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 1).cgColor
        layer?.cornerRadius = 16
        
        // Outer padded view
        let paddedContainer = NSView()
        paddedContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(paddedContainer)
        
        NSLayoutConstraint.activate([
            paddedContainer.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            paddedContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            paddedContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            paddedContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
        
        // Vertical container
        container.orientation = .vertical
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        paddedContainer.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: paddedContainer.topAnchor),
            container.bottomAnchor.constraint(equalTo: paddedContainer.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: paddedContainer.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: paddedContainer.trailingAnchor)
        ])
        
        // Heading icon
        headingStack.orientation = .horizontal
        headingStack.spacing = 8
        headingStack.alignment = .centerY
        headingStack.translatesAutoresizingMaskIntoConstraints = false
        
        if let imageIcon = NSImage(systemSymbolName: "photo.on.rectangle", accessibilityDescription: nil) {
            iconView.image = imageIcon
            iconView.symbolConfiguration = .init(pointSize: 18, weight: .regular)
            iconView.contentTintColor = NSColor(calibratedWhite: 0.7, alpha: 1)
        }
        headingStack.addArrangedSubview(iconView)
        
        let attributed = NSMutableAttributedString()
        attributed.append(NSAttributedString(
            string: "Recent ",
            attributes: [.font: NSFont.systemFont(ofSize: 18, weight: .semibold),
                         .foregroundColor: NSColor.white]
        ))
        attributed.append(NSAttributedString(
            string: "Screenshots",
            attributes: [.font: NSFont.systemFont(ofSize: 18, weight: .regular),
                         .foregroundColor: NSColor(calibratedWhite: 0.7, alpha: 1)]
        ))
        headingLabel.attributedStringValue = attributed
        headingLabel.isBezeled = false
        headingLabel.drawsBackground = false
        headingLabel.isEditable = false
        headingLabel.backgroundColor = .clear
        headingLabel.setContentHuggingPriority(.required, for: .horizontal)
        headingStack.addArrangedSubview(headingLabel)
        
        // Wrapper to apply 16pt top padding to heading
        let headingWrapper = NSView()
        headingWrapper.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(headingWrapper)
        
        headingWrapper.addSubview(headingStack)
        NSLayoutConstraint.activate([
            headingStack.topAnchor.constraint(equalTo: headingWrapper.topAnchor, constant: 16),
            headingStack.leadingAnchor.constraint(equalTo: headingWrapper.leadingAnchor),
            headingStack.trailingAnchor.constraint(equalTo: headingWrapper.trailingAnchor),
            headingStack.bottomAnchor.constraint(equalTo: headingWrapper.bottomAnchor)
        ])
        
        // Content wrapper
        container.addArrangedSubview(contentWrapper)
        
        contentWrapper.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentWrapper.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        contentWrapper.heightAnchor.constraint(lessThanOrEqualTo: container.heightAnchor, multiplier: 1.0).isActive = true
        
        
        // No screenshot fallback
        noScreenshotLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        noScreenshotLabel.textColor = NSColor(calibratedWhite: 0.7, alpha: 1)
        noScreenshotLabel.drawsBackground = false
        noScreenshotLabel.isBezeled = false
        noScreenshotLabel.isEditable = false
        noScreenshotLabel.alignment = .center
        noScreenshotLabel.translatesAutoresizingMaskIntoConstraints = false
        contentWrapper.addSubview(noScreenshotLabel)
        
        NSLayoutConstraint.activate([
            noScreenshotLabel.centerXAnchor.constraint(equalTo: contentWrapper.centerXAnchor),
            noScreenshotLabel.centerYAnchor.constraint(equalTo: contentWrapper.centerYAnchor)
        ])
        
        /*    // Temporary test image
         let testImageView = DraggableImageView(HomeWindow: nil)
         testImageView.translatesAutoresizingMaskIntoConstraints = false
         
         // 💡 Force full fill behavior:
         testImageView.imageScaling = .scaleAxesIndependently  // ← 🔥 This forces full stretch, no aspect-ratio
         testImageView.imageAlignment = .alignCenter
         
         testImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
         testImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
         
         contentWrapper.addSubview(testImageView)
         
         NSLayoutConstraint.activate([
         testImageView.topAnchor.constraint(equalTo: contentWrapper.topAnchor),
         testImageView.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor),
         testImageView.leadingAnchor.constraint(equalTo: contentWrapper.leadingAnchor),
         testImageView.trailingAnchor.constraint(equalTo: contentWrapper.trailingAnchor)
         ])
         
         
         // Load test image from Unsplash
         if let url = URL(string: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80") {
         DispatchQueue.global().async {
         if let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
         DispatchQueue.main.async {
         testImageView.image = image
         self.noScreenshotLabel.isHidden = true
         }
         }
         }
         }
         }*/
    }

    func appendScreenshot(_ imageView: DraggableImageView) {
        currentDraggableImageView?.removeFromSuperview()
        currentDraggableImageView = imageView
        if let currentDraggableImageView = currentDraggableImageView {
        currentDraggableImageView.translatesAutoresizingMaskIntoConstraints = false
        contentWrapper.addSubview(currentDraggableImageView)

        currentDraggableImageView.imageScaling = .scaleAxesIndependently
        currentDraggableImageView.imageAlignment = .alignCenter
        currentDraggableImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        currentDraggableImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // full width and height of parent
        NSLayoutConstraint.activate([
            currentDraggableImageView.topAnchor.constraint(equalTo: contentWrapper.topAnchor),
            currentDraggableImageView.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor),
            currentDraggableImageView.leadingAnchor.constraint(equalTo: contentWrapper.leadingAnchor),
            currentDraggableImageView.trailingAnchor.constraint(equalTo: contentWrapper.trailingAnchor)
        ]) }

          // 💥 Force contentWrapper height to be fixed so image doesn’t push anything
    contentWrapper.heightAnchor.constraint(equalToConstant: contentWrapper.frame.height).isActive = true
        
        noScreenshotLabel.isHidden = true
    }

    func clearScreenshot() {
        currentDraggableImageView?.removeFromSuperview()
        currentDraggableImageView = nil
        noScreenshotLabel.isHidden = false
    }
}
