//
//  ContentView.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import SwiftUI
import WebKit

struct ContentView: View {
    var appCoordinator: AppCoordinator
    
    var body: some View {
        appCoordinator.chatGPTWebView
            .frame(minWidth: 800, minHeight: 600)
            .onAppear {
                NSApp.activate(ignoringOtherApps: true)
            }
    }
}



