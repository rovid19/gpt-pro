import Cocoa

class HomeWindowView: NSWindow {
    var homeView: HomeView?
    var homeViewController: HomeViewController
    var appDelegate: UserStoreDelegate?
        
    var screenshotAnimation: Bool = false {
         didSet {
             animateGlassmorphism(for: screenshotAnimation)
         }
     }
    private var visualEffectView: NSVisualEffectView?

    init (homeViewController:HomeViewController) {
        self.homeViewController = homeViewController
    
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
            view = homeViewController.renderHomeView(frame: visualEffectView?.bounds ?? .zero, homeViewController: self.homeViewController, appDelegate: self.appDelegate, authDelegate: self)
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



extension HomeWindowView: AuthViewDelegate {
    func authViewClosed() {
        visualEffectView?.subviews.forEach { $0.removeFromSuperview() }
    }

    func renderNewView(_ type: String) {
        renderView(type)
    }
}
