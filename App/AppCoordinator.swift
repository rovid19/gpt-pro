//
//  AppCoordinator.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Foundation
import Cocoa

class AppCoordinator: ObservableObject {
    // MARK: - Managers
    let shortcutManager: ShortcutManager
    
    // MARK: - Screenshot Components
    private var screenshotOverlayController: ScreenshotOverlayController?
    
    init() {
        self.shortcutManager = ShortcutManager()
        setupDelegates()
    }
    
    private func setupDelegates() {
        shortcutManager.setAppShortcutDelegate(self)
    }
    
    // MARK: - Screenshot Management
    
    func showScreenshotOverlay() {
        screenshotOverlayController = ScreenshotOverlayController(initialRect: CGRect(x: 0, y: 0, width: 400, height: 300))
        // kad stavim da je appcoordinator delegate screenshotoverlaycontroller, onda to znaci da unutar tog controllea
        // mogu pozvati funkcije iz appcoordinatora
        // znaci dobivam keyword "delegate" kojeg mogu koristiti
        // npr. delegate.hideScreenshotOverlay() i sad pozovem funkciju s tog delegatea
        screenshotOverlayController?.delegate = self
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
        NSLog("[gptapp] Screenshot captured - size: %dx%d", image.width, image.height)
        hideScreenshotOverlay()
    }
}
