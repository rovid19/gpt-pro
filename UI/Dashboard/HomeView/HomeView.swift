import Cocoa

class HomeView: NSView {
    private let padding: CGFloat = 32
    private let logoutButton: NSButton = {
        let button = NSButton(title: "Logout", target: nil, action: nil)
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var savedChatsView: SavedChatsView
    private var recentScreenshotsView: RecentScreenshotsView

    private weak var appDelegate: UserStoreDelegate?
    private weak var authDelegate: AuthViewDelegate?

    init(
        frame: NSRect,
        savedChatsView: SavedChatsView,
        recentScreenshotsView: RecentScreenshotsView,
        appDelegate: UserStoreDelegate?,
        authDelegate: AuthViewDelegate?
    ) {

        self.appDelegate = appDelegate
        self.authDelegate = authDelegate
        self.savedChatsView = savedChatsView
        self.recentScreenshotsView = recentScreenshotsView

        super.init(frame: frame)

        autoresizingMask = [.width, .height]

        addSubview(logoutButton)

        logoutButton.target = self
        logoutButton.action = #selector(handleLogout)

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 80),
            logoutButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        // Sidebar: Saved Chats
        let sidebarWidth = bounds.width * 0.25
        savedChatsView.frame = NSRect(
            x: padding,
            y: padding,
            width: sidebarWidth,
            height: bounds.height - 2 * padding
        )

        // Bottom-right: Recent Screenshots
        let width: CGFloat = 340
        let height: CGFloat = 320
        recentScreenshotsView.frame = NSRect(
            x: bounds.width - width - padding,
            y: padding,
            width: width,
            height: height
        )

        // Logout button (already constrained, but reposition on resize)
        logoutButton.frame = NSRect(
            x: bounds.width - 96,
            y: bounds.height - 48,
            width: 80,
            height: 32
        )
    }

    @objc func handleLogout() {
        Task {
            do {
                try await AuthService.shared.logout()
                authDelegate?.authViewClosed()
                appDelegate?.userDidLogout()
            } catch {
                print("Logout failed: \(error)")
            }
        }
    }
}
