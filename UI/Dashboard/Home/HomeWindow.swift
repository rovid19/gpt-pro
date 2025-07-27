import Cocoa

class HomeView: NSView {
    var homeViewController: HomeViewController?
     var recentScreenshotsView: RecentScreenshotsView?
     var savedChatsView: SavedChatsView?
     var savedChatsController: SavedChatsController?
     weak var appDelegate: UserStoreDelegate?
     weak var authDelegate: AuthViewDelegate?
    private let logoutButton: NSButton = {
        let button = NSButton(title: "Logout", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
     
    private let padding: CGFloat = 32
     init(frame: NSRect, appDelegate: UserStoreDelegate?, authDelegate: AuthViewDelegate?, homeViewController: HomeViewController) {
        super.init(frame: frame)
        self.appDelegate = appDelegate
        self.authDelegate = authDelegate
        self.homeViewController = homeViewController
        // Add RecentScreenshotsView as a 400x400 container in bottom right
        let recentScreenshotsFrame = NSRect(
            x: frame.width - 400 - padding,
            y: frame.height - 400 - padding,
            width: 400,
            height: 400
        )
        let recentScreenshotsView = RecentScreenshotsView(frame: recentScreenshotsFrame)
        self.addSubview(recentScreenshotsView)
        self.recentScreenshotsView = recentScreenshotsView
        self.autoresizingMask = [.width, .height]

        // Add logout button
        logoutButton.target = self
        logoutButton.action = #selector(handleLogout)
        self.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 80),
            logoutButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Add SavedChatsView
        let sidebarWidth = frame.width * 0.25
        let savedChatsView = SavedChatsView(frame: NSRect(x: padding, y: padding, width: sidebarWidth, height: frame.height - 2 * padding))
        self.addSubview(savedChatsView)
        self.savedChatsView = savedChatsView
        self.autoresizingMask = [.width, .height]

        // Create SavedChatsController and connect to WebSocketBridge
        let savedChatsController = SavedChatsController(savedChatsView: savedChatsView)
        self.savedChatsController = savedChatsController
        if let appDelegate = appDelegate as? AppCoordinator {
            appDelegate.wsBridge?.setSavedChatsController(savedChatsController)
            NSLog("[gptapp] Connected SavedChatsController to WebSocketBridge")
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layout() {
        super.layout()
        // Position RecentScreenshotsView in the bottom right corner
        if let recentScreenshotsView = recentScreenshotsView {
            let width: CGFloat = 340
            let height: CGFloat = 320
            let padding: CGFloat = 32
            recentScreenshotsView.frame = NSRect(
                x: self.bounds.width - width - padding,
                y: padding,
                width: width,
                height: height
            )
        }
        // Move logout button to top right on resize
        logoutButton.frame = NSRect(x: self.bounds.width - 96, y: self.bounds.height - 48, width: 80, height: 32)
        // (You can also update SavedChatsView layout here if needed)
    }

    @objc func handleLogout() {
        Task {
            do {
                try await AuthService.shared.logout()
                authDelegate?.authViewClosed()
                appDelegate?.userDidLogout()
            }
            catch {
                print("Logout failed: \(error)")
            }
        }
    }
}

class HomeWindow: NSWindow {
    var homeView: HomeView?
    var homeViewController: HomeViewController?
    var appDelegate: UserStoreDelegate?
        
     var screenshotAnimation: Bool = false {
         didSet {
             animateGlassmorphism(for: screenshotAnimation)
         }
     }
    private var visualEffectView: NSVisualEffectView?
    init(homeViewController: HomeViewController) {
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        super.init(contentRect: screenFrame, styleMask: [.borderless], backing: .buffered, defer: false)

        self.isOpaque = false
        self.backgroundColor = .clear

        self.level = .screenSaver  // ← this makes it float above everything
        self.ignoresMouseEvents = false  // ← set to true if it should be click-through
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]  // ← stays across Spaces

        self.hasShadow = false
        self.isMovableByWindowBackground = false
        self.homeViewController = homeViewController
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
    }

    func renderView(_ type: String, appDelegate: UserStoreDelegate? = nil) {
        if self.appDelegate == nil, let delegate = appDelegate {
            self.appDelegate = delegate
        }

        NSLog("[gptapp] [HomeWindow] appdelegate \(appDelegate), ")
        NSLog("[gptapp] [HomeWindow] rendering view: \(type)")
        // Remove all previous subviews
        visualEffectView?.subviews.forEach { $0.removeFromSuperview() }
        let view: NSView
        if type == "home" {
            NSLog("[gptapp] [HomeWindow] rendering home view")
            view = HomeView(frame: visualEffectView?.bounds ?? .zero, appDelegate: self.appDelegate, authDelegate: self, homeViewController: self.homeViewController)
            self.homeView = view as? HomeView
        } else if type == "login" {
            NSLog("[gptapp] [HomeWindow] rendering login view")
            view = LoginView(frame: visualEffectView?.bounds ?? .zero, appDelegate: self.appDelegate, authDelegate: self)
        }
        else {
            NSLog("[gptapp] [HomeWindow] rendering register view")
            view = RegisterView(frame: visualEffectView?.bounds ?? .zero, appDelegate: self.appDelegate, authDelegate: self)
        }
        view.autoresizingMask = [.width, .height]
        visualEffectView?.addSubview(view)
    }

    func animateGlassmorphism(for state: Bool) {

        guard let visualEffectView = self.visualEffectView else { return }
        NSAnimationContext.runAnimationGroup { context in   
            context.duration = 0.3
            if state {
                // Transparent when screenshotAnimation is true
                visualEffectView.animator().alphaValue = 0.0
            } else {
                // Glassmorphism visible when screenshotAnimation is false
                visualEffectView.material = .hudWindow
                visualEffectView.state = .active
                visualEffectView.animator().alphaValue = 1.0
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeMain: Bool { true }
    override var canBecomeKey: Bool { true }

    override func becomeKey() {
        super.becomeKey()
        self.visualEffectView?.alphaValue = 1.0
    }
}



extension HomeWindow: AuthViewDelegate {
    func authViewClosed() {
        visualEffectView?.subviews.forEach { $0.removeFromSuperview() }
    }

    func renderNewView(_ type: String) {
        renderView(type)
    }
}
