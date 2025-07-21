//
//  GlobalShortcut.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Foundation
import HotKey
import Cocoa

protocol GlobalShortcutDelegate: AnyObject {
    func globalShortcutDidRequestScreenshotMode()
    func globalShortcutDidRequestToExitScreenshotMode()
}


class GlobalShortcut {
    var screenshotHotKey: HotKey?
    var exitScreenshotHotKey: HotKey?
    weak var delegate: GlobalShortcutDelegate?
    
    func setup() {
        // Register Option + Command + Enter as a global shortcut
        screenshotHotKey = HotKey(key: .return, modifiers: [.option, .command])
        screenshotHotKey?.keyDownHandler = { [weak self] in
            DispatchQueue.main.async {
                //NSApp.activate(ignoringOtherApps: true)
                self?.delegate?.globalShortcutDidRequestScreenshotMode()
                NSLog("[gptapp] [GlobalShortcut] globalShortcutDidRequestScreenshotMode")
            }
        }
        
        // Register Command + Escape as a global shortcut
        exitScreenshotHotKey = HotKey(key: .escape, modifiers: [.command])
        exitScreenshotHotKey?.keyDownHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.globalShortcutDidRequestToExitScreenshotMode()
                NSLog("[gptapp] [GlobalShortcut] globalShortcutDidRequestToExitScreenshotMode")
            }
        }
    }
}

