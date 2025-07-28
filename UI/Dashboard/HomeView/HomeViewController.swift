import Cocoa

class HomeViewController: NSViewController {
    var homeView: HomeView!
    var savedChatsController: SavedChatsController!
    var recentScreenshotsController: RecentScreenshotsController!

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        createSavedChatsController()
        createRecentScreenshotsController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSavedChatsController()
        createRecentScreenshotsController()
    }

    func renderHomeView(frame: NSRect, homeViewController _: HomeViewController, appDelegate: UserStoreDelegate? = nil, authDelegate: AuthViewDelegate? = nil) -> HomeView {
        let homeView = HomeView(
            frame: frame,
            savedChatsView: savedChatsController.savedChatsView,
            recentScreenshotsView: recentScreenshotsController.recentScreenshotsView,
            appDelegate: appDelegate,
            authDelegate: authDelegate
        )

        homeView.addSubview(savedChatsController.savedChatsView)
        homeView.addSubview(recentScreenshotsController.recentScreenshotsView)

        self.homeView = homeView

        return homeView
    }

    func createRecentScreenshotsController() {
        let recentScreenshotsController = RecentScreenshotsController()
        self.recentScreenshotsController = recentScreenshotsController
    }

    func createSavedChatsController() {
        let savedChatsController = SavedChatsController()
        self.savedChatsController = savedChatsController
    }
}
