//
//  HotKeyManager.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import SwiftUI
import HotKey
import WebKit

class HotKeyManager: ObservableObject {
    var hotKey: HotKey?
    var newChatHotKey: HotKey?
    private var webView: WKWebView?
    
    init() {
        setup()
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    func setup() {
        // Configure main hotkey with global priority
        hotKey = HotKey(key: .space, modifiers: [.option])
        hotKey?.keyDownHandler = {
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                
                // Always bring app to front, regardless of window state
                if let window = NSApp.windows.first {
                    window.orderFront(nil)
                    window.makeKey()
                    
                    // If window was minimized, restore it
                    if window.isMiniaturized {
                        window.deminiaturize(nil)
                    }
                } else {
                    // If no window exists, create one
                    NSApp.sendAction(Selector(("newWindow:")), to: nil, from: nil)
                }
            }
        }
        
        // Configure new chat hotkey
        newChatHotKey = HotKey(key: .n, modifiers: [.option])
        newChatHotKey?.keyDownHandler = {
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                
                // Always create a new window for new chat
                if let window = NSApp.windows.first {
                    window.orderFront(nil)
                    window.makeKey()
                    
                    // If window was minimized, restore it
                    if window.isMiniaturized {
                        window.deminiaturize(nil)
                    }
                    
                    // Use stored webView reference if available
                    if let webView = self.webView {
                        let shortcutScript = """
                        try {
                            // Create a more robust keyboard event
                            const event = new KeyboardEvent('keydown', {
                                key: 'O',
                                code: 'KeyO',
                                keyCode: 79,
                                which: 79,
                                ctrlKey: false,
                                shiftKey: true,
                                altKey: false,
                                metaKey: true,
                                bubbles: true,
                                cancelable: true,
                                composed: true
                            });
                            
                            // Dispatch to document
                            document.dispatchEvent(event);
                        } catch (error) {
                            console.error('Error dispatching keyboard event:', error);
                        }
                        """
                        webView.evaluateJavaScript(shortcutScript) { result, error in
                            // JavaScript execution completed
                        }
                    }
                } else {
                    // If no window exists, create one
                    NSApp.sendAction(Selector(("newWindow:")), to: nil, from: nil)
                }
            }
        }
    }
} 