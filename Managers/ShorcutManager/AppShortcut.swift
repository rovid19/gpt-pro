//
//  AppShortcut.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Foundation
import HotKey
import Cocoa

// Global variable to track screenshot mode
var isScreenshotModeOn = false

protocol AppShortcutDelegate: AnyObject {
    func appShortcutDidRequestScreenshotMode()
    func appShortcutDidRequestExitScreenshotMode()
}

class AppShortcut {
    weak var delegate: AppShortcutDelegate?
    var screenshotHotKey: HotKey?
    var exitScreenshotHotKey: HotKey?
    
    func registerScreenshotHotkeys() {
        // Configure screenshot mode hotkey
        screenshotHotKey = HotKey(key: .return, modifiers: [.command])
        screenshotHotKey?.keyDownHandler = {
            DispatchQueue.main.async {
                NSLog("[gptapp] Cmd+Enter pressed - entering screenshot mode")
                isScreenshotModeOn = true
                NSLog("[gptapp] Screenshot mode enabled: %@", isScreenshotModeOn ? "true" : "false")
                self.delegate?.appShortcutDidRequestScreenshotMode()
            }
        }
        
        // Configure exit screenshot mode hotkey (works globally when screenshot mode is active)
        exitScreenshotHotKey = HotKey(key: .escape, modifiers: [.command])
        exitScreenshotHotKey?.keyDownHandler = {
            DispatchQueue.main.async {
                if isScreenshotModeOn {
                    NSLog("[gptapp] Cmd+Esc pressed - exiting screenshot mode")
                    isScreenshotModeOn = false
                    NSLog("[gptapp] Screenshot mode disabled: %@", isScreenshotModeOn ? "true" : "false")
                    self.delegate?.appShortcutDidRequestExitScreenshotMode()
                    
                } else {
                    NSLog("[gptapp] Cmd+Esc pressed - screenshot mode not active")
                }
            }
        }
    }
    
    func unregisterScreenshotHotkeys() {
        NSLog("[gptapp] App became inactive - unregistering screenshot hotkeys")
        screenshotHotKey = nil
        exitScreenshotHotKey = nil
    }
}
