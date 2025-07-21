import Cocoa

class HomeView: NSView {
     var recentScreenshotsView: RecentScreenshotsView?
    private let padding: CGFloat = 32
    override init(frame: NSRect) {
        super.init(frame: frame)
        // Add RecentScreenshotsView as a sidebar inside HomeView
        let sidebarWidth = frame.width * 0.15
        let sidebarFrame = NSRect(x: padding, y: padding, width: sidebarWidth, height: frame.height - 2 * padding)
        let recentScreenshotsView = RecentScreenshotsView(frame: sidebarFrame)
        self.addSubview(recentScreenshotsView)
        self.recentScreenshotsView = recentScreenshotsView
        self.autoresizingMask = [.width, .height]
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layout() {
        super.layout()
        // Layout RecentScreenshotsView with 32px padding on all sides
        if let recentScreenshotsView = recentScreenshotsView {
            let sidebarWidth = self.bounds.width * 0.15
            recentScreenshotsView.frame = NSRect(x: padding, y: padding, width: sidebarWidth, height: self.bounds.height - 2 * padding)
        }
    }
}

class HomeWindow: NSWindow {
     var homeView: HomeView?
    private var visualEffectView: NSVisualEffectView?
    init() {
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        super.init(contentRect: screenFrame, styleMask: [.borderless], backing: .buffered, defer: false)

        self.isOpaque = false
        self.backgroundColor = .clear

        self.level = .screenSaver  // ← this makes it float above everything
        self.ignoresMouseEvents = false  // ← set to true if it should be click-through
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]  // ← stays across Spaces

        self.hasShadow = false
        self.isMovableByWindowBackground = false
        self.delegate = windowDelegate

        // Add glassmorphism effect
        let visualEffectView = NSVisualEffectView(frame: screenFrame)
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 0
        self.contentView = visualEffectView
        self.visualEffectView = visualEffectView

        // Add HomeView to fill the window
        let homeView = HomeView(frame: visualEffectView.bounds)
        homeView.autoresizingMask = [.width, .height]
        visualEffectView.addSubview(homeView)
        self.homeView = homeView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
