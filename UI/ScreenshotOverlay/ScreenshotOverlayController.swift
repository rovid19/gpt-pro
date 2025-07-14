//
//  ScreenshotOverlayController.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Foundation
import Cocoa

protocol ScreenshotOverlayControllerDelegate: AnyObject {
    func screenshotOverlayDidRequestExit()
    func screenshotOverlayDidCaptureImage(_ image: CGImage)
}

class ScreenshotOverlayController: NSResponder {
    weak var delegate: ScreenshotOverlayControllerDelegate?
    private let screenshotService = ScreenshotService()
    private let overlayView: ScreenshotOverlayView
    private let minSize: CGFloat = 100


    init(initialRect: CGRect) {
        self.overlayView = ScreenshotOverlayView(initialRect: initialRect)
        super.init()
        
        setupView()
        setupEventHandling()
        showOverlay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }  
    
    private func setupView() {
        overlayView.controller = self
    }
    
    private func setupEventHandling() {
        setupMagnifyGesture()
        setupKeyboardHandling()
        enableMouseTracking()
    }
    
    private func setupMagnifyGesture() {
        let magnifyRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnify(_:)))
        overlayView.addGestureRecognizer(magnifyRecognizer)
    }
    
    @objc private func handleMagnify(_ gesture: NSMagnificationGestureRecognizer) {
        handleMagnify(scale: gesture.magnification)
    }
    

    
    private func setupKeyboardHandling() {
        // Keyboard monitoring will be set up when overlay is shown
    }
    
    private func enableMouseTracking() {
        overlayView.window?.acceptsMouseMovedEvents = true
        overlayView.window?.ignoresMouseEvents = false
        overlayView.addTrackingArea(NSTrackingArea(
            rect: overlayView.bounds,
            options: [.activeAlways, .mouseMoved, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
    }
    
    override func mouseMoved(with event: NSEvent) {
        let mouseLocation = NSEvent.mouseLocation
        let newOrigin = CGPoint(
            x: mouseLocation.x - overlayView.frame.size.width / 2,
            y: mouseLocation.y - overlayView.frame.size.height / 2
        )

        var newFrame = CGRect(origin: newOrigin, size: overlayView.frame.size)

        if let screenFrame = NSScreen.main?.frame {
            newFrame = newFrame.intersection(screenFrame)
        }

        overlayView.setFrameOrigin(newFrame.origin)
        overlayView.updateBorder()
    }
    
    // MARK: - Event Handling
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
        handleKeyDown(keyCode: Int(event.keyCode))
    }
    
    func showOverlay() {
        // Position the frame at the current mouse location
        let mouseLocation = NSEvent.mouseLocation
        let frameSize = CGSize(width: 400, height: 300)
        let frameOrigin = CGPoint(
            x: mouseLocation.x - frameSize.width / 2,
            y: mouseLocation.y - frameSize.height / 2
        )
        let frameRect = CGRect(origin: frameOrigin, size: frameSize)
        
        overlayView.frame = frameRect
        overlayView.showOverlay()
    }
    
    func hideOverlay() {
        overlayView.hideOverlay()
    }
    
    // MARK: - Logic Methods
    
    private func resizeFrame(by delta: CGFloat) {
        let newWidth = overlayView.frame.width + delta
        let newHeight = overlayView.frame.height + delta
        guard newWidth >= minSize, newHeight >= minSize else { return }
        
        let newOrigin = CGPoint(
            x: overlayView.frame.origin.x - delta / 2,
            y: overlayView.frame.origin.y - delta / 2
        )
        
        let newFrame = CGRect(origin: newOrigin, size: CGSize(width: newWidth, height: newHeight))
        overlayView.animateFrame(to: newFrame)
    }
    
    private func rotateFrame() {
        overlayView.rotateFrame()
    }
    
    private func handleMagnify(scale: CGFloat) {
        let dx = overlayView.frame.width * scale * 0.5
        let dy = overlayView.frame.height * scale * 0.5
        var newRect = overlayView.frame.insetBy(dx: dx, dy: dy)
        
        if newRect.width < minSize || newRect.height < minSize {
            return
        }
        
        if let screenFrame = NSScreen.main?.frame {
            newRect = newRect.intersection(screenFrame)
        }
        
        overlayView.animateFrame(to: newRect)
    }
    
    func handleKeyDown(keyCode: Int) {
        switch keyCode {
        case 15: // R key
            rotateFrame()
        case 126: // Up arrow
            resizeFrame(by: 20)
        case 125: // Down arrow
            resizeFrame(by: -20)
        case 36: // Enter key
            requestCapture()
        case 53: // Escape key
            requestExit()
        default:
            break
        }
    }
    
    private func requestCapture() {
        let cropRect = overlayView.frame
        
        screenshotService.captureOnce { fullImage in
            guard let fullImage = fullImage else { return }
            
            let flippedRect = CGRect(
                x: cropRect.origin.x,
                y: CGFloat(fullImage.height) - cropRect.origin.y - cropRect.height,
                width: cropRect.width,
                height: cropRect.height
            )
            
            guard let cropped = fullImage.cropping(to: flippedRect) else { return }
            
            self.delegate?.screenshotOverlayDidCaptureImage(cropped)
        }
    }
    
    private func requestExit() {
        delegate?.screenshotOverlayDidRequestExit()
    }
}
