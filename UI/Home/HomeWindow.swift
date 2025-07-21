import Cocoa

class HomeWindow: NSWindow {
    init() {
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        super.init(contentRect: screenFrame, styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        backgroundColor = NSColor.black.withAlphaComponent(0.5)
        isOpaque = false
        self.delegate = windowDelegate
        makeKeyAndOrderFront(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
