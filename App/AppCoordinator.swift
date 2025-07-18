//
//  AppCoordinator.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Foundation
import Cocoa
import WebKit
import SwiftUI
import AppKit
class AppCoordinator: ObservableObject {
    // MARK: - Managers
    let shortcutManager: ShortcutManager
    
    // MARK: - Screenshot Components
    private var screenshotOverlayController: ScreenshotOverlayController?
    private var screenshotPreviewController: ScreenshotPreviewController?
    
    // MARK: - WebView
    // WKWebView-related properties removed due to project pivot
    
    var homeView: NSView?
    var window: NSWindow? 


    init() {
        self.shortcutManager = ShortcutManager()
        setupDelegates()
      
    }
    
    private func setupDelegates() {
        shortcutManager.setAppShortcutDelegate(self)
    }

    func test() {
        NSLog("test homeHostingView: \(String(describing: homeView))")
    
    }
    // MARK: - Screenshot Management
    
    func showScreenshotOverlay() {
        screenshotOverlayController = ScreenshotOverlayController(initialRect: CGRect(x: 0, y: 0, width: 400, height: 300))
        screenshotOverlayController?.delegate = self
        // If needed, pass other dependencies to overlay
    }
    
    func hideScreenshotOverlay() {
        screenshotOverlayController?.hideOverlay()
        screenshotOverlayController = nil
    }
}








// MARK: - AppShortcutDelegate

extension AppCoordinator: AppShortcutDelegate {
    func appShortcutDidRequestScreenshotMode() {
        showScreenshotOverlay()
    }
    
    func appShortcutDidRequestExitScreenshotMode() {
        hideScreenshotOverlay()
    }
}

// MARK: - ScreenshotOverlayControllerDelegate

extension AppCoordinator: ScreenshotOverlayControllerDelegate {
    func screenshotOverlayDidRequestExit() {
        hideScreenshotOverlay()
    }
    
  func screenshotOverlayDidCaptureImage(_ image: CGImage) {
    NSLog("[gptapp] [Preview] Entered screenshotOverlayDidCaptureImage")
     NSLog("pre homeHostingView: \(String(describing: homeView) )")
        NSLog("pre window: \(String(describing: window))")
    hideScreenshotOverlay()
         NSLog("post homeHostingView: \(String(describing: homeView))")
        NSLog("post window: \(String(describing: window?.contentView))")

    screenshotPreviewController = ScreenshotPreviewController()

    screenshotPreviewController?.showPreview(from: image, in: homeView!)
}


}
