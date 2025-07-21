//
//  mainApp.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    let coordinator = AppCoordinator()
    var homeWindow = HomeWindow()


    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationDidFinishLaunching")

        setupAppBehavior()
        checkAccessibilityPermission()
        checkScreenshotPermission()

        
        // Set up coordinator with the home window

        coordinator.homeWindow = homeWindow
        homeWindow.makeKeyAndOrderFront(nil)
        homeWindow.makeMain() 
        coordinator.showHomeWindowIfNeeded = showHomeWindowIfNeeded
        
        NSLog("[gptapp] [AppDelegate] ✅  HomeWindow window created")
        NSLog("[gptapp] [AppDelegate] Window valid: \(homeWindow.isVisible)")
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        showHomeWindowIfNeeded()
    }
      func showHomeWindowIfNeeded() {
        if coordinator.isScreenshotMode {
            return
        }
        if !homeWindow.isVisible {
            homeWindow.makeKeyAndOrderFront(nil)
        }
        if homeWindow.isMiniaturized {
            homeWindow.deminiaturize(nil)
        }
    }
}

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false // Prevent window from actually closing
    }
    
    func windowWillClose(_ notification: Notification) {
        // Window close prevented
    }
}

let windowDelegate = WindowDelegate()

func setupAppBehavior() {
    // Prevent app from terminating when window is closed
    NSApp.setActivationPolicy(.regular)
}

func checkAccessibilityPermission() {
    if !AXIsProcessTrusted() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}

func checkScreenshotPermission() {
    if !CGPreflightScreenCaptureAccess() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
        NSWorkspace.shared.open(url)
    }
}

