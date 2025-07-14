//
//  ScreenshotOverlayView.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Cocoa

class ScreenshotOverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
// kad deklariram ovu klasu ko NSView ona ime po defoltu
// propertije za frame,bounds,layer,superview,subviews..
// to ne moram pisati to nsview ima u sebi
class ScreenshotOverlayView: NSView {
    weak var controller: ScreenshotOverlayController?
    var overlayWindow: ScreenshotOverlayWindow?
    
    let borderLayer = CAShapeLayer()
    private let scaleAnimationDuration = 0.1
    
    init(initialRect: CGRect) {
        super.init(frame: initialRect)
        wantsLayer = true
        setupBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBorder() {
        borderLayer.strokeColor = NSColor.systemBlue.cgColor
        borderLayer.lineWidth = 3
        borderLayer.fillColor = NSColor.clear.cgColor
        borderLayer.path = CGPath(rect: bounds, transform: nil)
        layer?.addSublayer(borderLayer)
    }
    
    // MARK: - Public UI Methods (Called by Controller)
    
    func updateBorder() {
    borderLayer.path = CGPath(rect: bounds, transform: nil)
}


    func animateFrame(to newFrame: CGRect) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = scaleAnimationDuration
            self.animator().setFrameOrigin(newFrame.origin)
            self.animator().setFrameSize(newFrame.size)
        })
        
        borderLayer.path = CGPath(rect: bounds, transform: nil)
    }
    
    func rotateFrame() {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        let newSize = CGSize(width: frame.height, height: frame.width)
        let newOrigin = CGPoint(
            x: center.x - newSize.width / 2,
            y: center.y - newSize.height / 2
        )

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = scaleAnimationDuration
            self.animator().setFrameOrigin(newOrigin)
            self.animator().setFrameSize(newSize)
        })

        borderLayer.path = CGPath(rect: bounds, transform: nil)
    }
    
     func showOverlay() {
        let screenFrame = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
        
        let overlayWindow = ScreenshotOverlayWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        overlayWindow.level = .screenSaver
        overlayWindow.backgroundColor = NSColor.clear
        overlayWindow.isOpaque = false
        overlayWindow.hasShadow = false
        overlayWindow.ignoresMouseEvents = false
        overlayWindow.acceptsMouseMovedEvents = true
        self.overlayWindow = overlayWindow

        let frameSize = CGSize(width: 400, height: 300)
        let frameOrigin = CGPoint(
            x: screenFrame.midX - frameSize.width / 2,
            y: screenFrame.midY - frameSize.height / 2
        )
        let frameRect = CGRect(origin: frameOrigin, size: frameSize)

        self.frame = frameRect
        overlayWindow.contentView?.addSubview(self)

        self.overlayWindow?.makeKeyAndOrderFront(nil)
        self.overlayWindow?.makeFirstResponder(controller)
    }

    
    func hideOverlay() {
        overlayWindow?.orderOut(nil) 
        overlayWindow = nil
        removeFromSuperview()
    }
    

    
    override var acceptsFirstResponder: Bool { true }
} 
