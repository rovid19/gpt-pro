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

        
        NSLog("[gptapp] [AppDelegate] ✅  HomeWindow window created")
        NSLog("[gptapp] [AppDelegate] Window valid: \(homeWindow.isVisible)")
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        showHomeWindowIfNeeded()
    }
 func showHomeWindowIfNeeded() {
    NSLog("[gptapp] [AppDelegate] ShowHomeWindowIfNeeded1")
    if coordinator.isScreenshotMode {
        return
    }
    NSLog("[gptapp] [AppDelegate] showHomeWindowIfNeeded2")
    // 🔥 This is the key line that forces a full switch to the app, including Space
    NSRunningApplication.current.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])

    if homeWindow.isMiniaturized {
        homeWindow.deminiaturize(nil)
    }

    homeWindow.makeKeyAndOrderFront(nil)
    NSLog("[gptapp] [AppDelegate] homewindow is visible: \(homeWindow.isVisible)")
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

