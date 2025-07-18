//
//  ShortcutManager.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import SwiftUI
import WebKit

class ShortcutManager: ObservableObject {
    private let globalShortcut = GlobalShortcut()
    private let appShortcut = AppShortcut()
    
    init() {
        setup()
        setupAppStateMonitoring()
    }
    
    func setWebView(_ webView: WKWebView) {
        globalShortcut.setWebView(webView)
    }
    
    func setAppShortcutDelegate(_ delegate: AppShortcutDelegate) {
        appShortcut.delegate = delegate
    }
    
    private func setupAppStateMonitoring() {
        // Monitor app activation/deactivation to manage screenshot hotkeys
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.appShortcut.registerScreenshotHotkeys()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.appShortcut.unregisterScreenshotHotkeys()
        }
    }
    
    private func setup() {
        // Setup global shortcuts (work even when app is hidden/minimized)
        globalShortcut.setup()
        
        // Register app shortcuts initially if app is active
        if NSApp?.isActive == true {
            appShortcut.registerScreenshotHotkeys()
        }
    }
} 
