//
//  mainApp.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Cocoa
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let coordinator = AppCoordinator()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationDidFinishLaunching")

        setupAppBehavior()
        checkAccessibilityPermission()
        checkScreenshotPermission()

        let homeView = HomeView(frame: NSRect(x: 0, y: 0, width: 1280, height: 800))
        // If you have a HomeViewController, set it up here and assign to homeView.controller if needed

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.contentView?.addSubview(homeView)
        homeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            homeView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
            homeView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            homeView.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor)
        ])

        window.makeKeyAndOrderFront(nil)
        window.delegate = windowDelegate
        NSApp.activate(ignoringOtherApps: true)

        coordinator.homeView = homeView
        // coordinator.test() or other setup if needed

        NSLog("[gptapp] [AppDelegate] ✅ Attached HomeView to window")
        NSLog("[gptapp] [AppDelegate] Frame: \(homeView.frame)")
        NSLog("[gptapp] [AppDelegate] Window valid: \(homeView.window != nil)")
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
    // Set up window delegate to handle window closing
    if let window = NSApp.windows.first {
        window.delegate = windowDelegate
        // Removed floating, ignoresMouseEvents, isOpaque, and backgroundColor settings
    }
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

