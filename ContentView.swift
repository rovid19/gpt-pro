//
//  ContentView.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import SwiftUI
import WebKit

struct ContentView: View {
    var hotKeyManager: HotKeyManager
    @State private var webView: WKWebView?
    
    var body: some View {
        ChatGPTWebView { webView in
            self.webView = webView
            self.hotKeyManager.setWebView(webView)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

#Preview {
    ContentView(hotKeyManager: HotKeyManager())
}


