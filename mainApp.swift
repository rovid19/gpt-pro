//
//  mainApp.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import SwiftUI
import Cocoa
import ApplicationServices

@main
struct gpt_pro_appApp: App {
    @StateObject private var hotKeyManager = HotKeyManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(hotKeyManager: hotKeyManager)
                .onAppear {
                    checkAccessibilityPermission()
                    setupAppBehavior()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

func setupAppBehavior() {
    // Prevent app from terminating when window is closed
    NSApp.setActivationPolicy(.regular)
    
    // Set up window delegate to handle window closing
    if let window = NSApp.windows.first {
        window.delegate = WindowDelegate()
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

func checkAccessibilityPermission() {
    if !AXIsProcessTrusted() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
} 