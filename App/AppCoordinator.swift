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
    var homeViewController: HomeViewController?
    var isScreenshotMode = false

    var wsBridge: WebSocketBridge?

    var userStore: UserStore?
   
    init() {    
        self.shortcutManager = ShortcutManager()
        shortcutManager.globalShortcut.delegate = self
        self.wsBridge = WebSocketBridge()
        self.userStore = UserStore()
    }
    
    // MARK: - Screenshot Management
    
func showScreenshotOverlay() {
    screenshotOverlayController = ScreenshotOverlayController(initialRect: CGRect(x: 0, y: 0, width: 400, height: 300))
    screenshotOverlayController?.delegate = self
}

func determineCurrentView() {
    NSLog("[gptapp] [AppCoordinator] determining current view")
    Task {
        if await userStore?.isUserLoggedIn() == false {
            NSLog("[gptapp] [AppCoordinator] user not logged in, rendering login view \(self.homeWindow)")
            homeWindow?.renderView("login", appDelegate: self)
        } else {
            NSLog("[gptapp] [AppCoordinator] user logged in, rendering home view")
             homeWindow?.renderView("home", appDelegate: self)
        }
    }
  
}

    
func hideScreenshotOverlay() {
        screenshotOverlayController?.hideOverlay()
        screenshotOverlayController = nil
    }
}


// MARK: - ScreenshotOverlayControllerDelegate

extension AppCoordinator: ScreenshotOverlayControllerDelegate {
    func screenshotOverlayDidRequestExit() {
        hideScreenshotOverlay()
    }
    
    func screenshotOverlayDidCaptureImage(_ image: CGImage) {
        NSLog("[gptapp] [AppCoordinator] image captured")
        isScreenshotMode = false
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.showHomeWindowIfNeeded()
        }
        hideScreenshotOverlay()
        screenshotPreviewController = ScreenshotPreviewController()
        screenshotPreviewController?.showPreview(from: image, in: homeWindow!)
    }


}

extension AppCoordinator: GlobalShortcutDelegate {
    func globalShortcutDidRequestScreenshotMode() {
        NSLog("[gptapp] [AppCoordinator] homeWindow \(homeWindow)")
        NSLog("[gptapp] [AppCoordinator] screenshot mode requested")
        isScreenshotMode = true
        homeWindow?.orderOut(nil) // Hide main overlay window when entering screenshot mode
        showScreenshotOverlay()
    }

    func globalShortcutDidRequestToExitScreenshotModeOrMinimizeApp() {
        if !isScreenshotMode {
            NSApp.hide(nil)
        }
        else {
 isScreenshotMode = false
        hideScreenshotOverlay()
        }
       
    }

    func globalShortcutDidRequestToOpenApp() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.showHomeWindowIfNeeded()
        }
    }
}

extension AppCoordinator: UserStoreDelegate {
    func userDidAuth(email: String) {
        NSLog("[gptapp] [AppCoordinator] user logged in or registered")
        determineCurrentView()
        userStore?.setUser(email: email)

    }

    func userDidLogout() {
        NSLog("[gptapp] [AppCoordinator] user logged out")
         userStore?.clearUser()
        determineCurrentView()
       
    }
}
