import Cocoa

protocol HomeViewControllerDelegate: AnyObject {
    func homeViewController(_ controller: HomeViewController, requestResizeWindowTo frame: CGRect)
}

class HomeViewController {
    weak var delegate: HomeViewControllerDelegate?
    
    func resizeWindow(to frame: CGRect) {
        if let window = NSApp.mainWindow {
            window.setFrame(frame, display: true)
            window.isOpaque = true
            window.backgroundColor = .clear
            window.ignoresMouseEvents = false
            window.level = .floating
            NSLog("[gptapp] [HomeViewController] Resized and repositioned main window to preview frame: \(frame)")
        } else {
            NSLog("[gptapp] [HomeViewController] ERROR: Could not get main window for preview positioning")
        }
    }
} 