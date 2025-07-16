//
//  AppCoordinator.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Foundation
import Cocoa
import WebKit

class AppCoordinator: ObservableObject {
    // MARK: - Managers
    let shortcutManager: ShortcutManager
    
    // MARK: - Screenshot Components
    private var screenshotOverlayController: ScreenshotOverlayController?
    
    // MARK: - WebView
    @Published var chatGPTWebView: ChatGPTWebView
    
    var screenshot: CGImage?
    
    init() {
        self.shortcutManager = ShortcutManager()
        self.chatGPTWebView = ChatGPTWebView()
        setupDelegates()
    }
    
    private func setupDelegates() {
        shortcutManager.setAppShortcutDelegate(self)
    }

    
    // MARK: - Screenshot Management
    
    func showScreenshotOverlay() {
        screenshotOverlayController = ScreenshotOverlayController(initialRect: CGRect(x: 0, y: 0, width: 400, height: 300))
        screenshotOverlayController?.delegate = self
        // If needed, pass chatGPTWebView or its WKWebView to overlay
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
        NSLog("[gptapp] AppCoordinator received screenshot from overlay delegate")
        screenshot = image
        NSLog("[gptapp] Screenshot saved to AppCoordinator property")
        hideScreenshotOverlay()
    }
}
