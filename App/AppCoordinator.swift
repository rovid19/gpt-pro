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
    
    var homeWindow: HomeWindow?
 var showHomeWindowIfNeeded: (() -> Void)?
    var isScreenshotMode = false
   

   


    init() {    
        self.shortcutManager = ShortcutManager()
        shortcutManager.globalShortcut.delegate = self
        //setupDelegates()
      
    }
    
   /* private func setupDelegates() {
        shortcutManager.setAppShortcutDelegate(self)
    }*/

    func test() {
        NSLog("test homeHostingView: \(String(describing: homeWindow))")
    
    }
    // MARK: - Screenshot Management
    
func showScreenshotOverlay() {

 
    screenshotOverlayController = ScreenshotOverlayController(initialRect: CGRect(x: 0, y: 0, width: 400, height: 300))
    screenshotOverlayController?.delegate = self
}

    
    func hideScreenshotOverlay() {
        screenshotOverlayController?.hideOverlay()
        screenshotOverlayController = nil
    }
}








// MARK: - AppShortcutDelegate
/*
extension AppCoordinator: AppShortcutDelegate {
    func appShortcutDidRequestScreenshotMode() {
        showScreenshotOverlay()
    }
    
    func appShortcutDidRequestExitScreenshotMode() {
        hideScreenshotOverlay()
    }
}
*/
// MARK: - ScreenshotOverlayControllerDelegate

extension AppCoordinator: ScreenshotOverlayControllerDelegate {
    func screenshotOverlayDidRequestExit() {
        hideScreenshotOverlay()
    }
    
    func screenshotOverlayDidCaptureImage(_ image: CGImage) {
        isScreenshotMode = false
        NSLog("[gptapp] image captured \(homeWindow)")
        if !homeWindow!.isVisible {
            NSLog("[gptapp] homeWindow is not visible")
           showHomeWindowIfNeeded?()
        }
        else {
            NSLog("[gptapp] homeWindow is visible")
        }
        hideScreenshotOverlay()
        screenshotPreviewController = ScreenshotPreviewController()
        screenshotPreviewController?.showPreview(from: image, in: homeWindow!)
    }


}

extension AppCoordinator: GlobalShortcutDelegate {
    func globalShortcutDidRequestScreenshotMode() {
        isScreenshotMode = true
        showScreenshotOverlay()
    }

    func globalShortcutDidRequestToExitScreenshotMode() {
        isScreenshotMode = false
        hideScreenshotOverlay()
    }
}
