//
//  ChatGPTWebView.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import SwiftUI
import WebKit

struct ChatGPTWebView: NSViewRepresentable {
    var onWebViewReady: ((WKWebView) -> Void)?
    private let webViewController = WebViewController()
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webViewController.attach(to: webView)
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        if let url = URL(string: "https://chat.openai.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ChatGPTWebView
        
        init(_ parent: ChatGPTWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onWebViewReady?(webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // Page failed to load
        }
    }
} 