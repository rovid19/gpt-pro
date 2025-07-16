import Foundation
import WebKit

class WebViewController: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    weak var webView: WKWebView?
    weak var appCoordinator: AppCoordinator?
    
    init(webView: WKWebView? = nil, appCoordinator: AppCoordinator? = nil) {
        self.webView = webView
        self.appCoordinator = appCoordinator
        super.init()
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.webView?.configuration.userContentController.add(self, name: "screenshot")
        self.webView?.configuration.userContentController.add(self, name: "gptapplog")
        injectMutationObserver()
    }
    
    func attach(to webView: WKWebView) {
        self.webView = webView
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: "screenshot")
        webView.configuration.userContentController.add(self, name: "gptapplog")
        injectMutationObserver()
    }
    
    private func injectMutationObserver() {
        guard let webView = self.webView else { return }
        NSLog("[gptapp] Injecting MutationObserver JS on webView setup")
        let js = """
        (function() {
            window.gptappLog = function(msg) {
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.gptapplog) {
                    window.webkit.messageHandlers.gptapplog.postMessage(msg);
                }
            };
            window.gptappLog('[gptapp] MutationObserver script running (setup)');
            if (window.__gptapp_fileupload_observer) return;
            window.__gptapp_fileupload_observer = true;
            const observer = new MutationObserver(() => {
                const fileInputs = Array.from(document.querySelectorAll('input[type=\"file\"]'));
                fileInputs.forEach(input => {
                    if (!input.__gptapp_listener) {
                        input.__gptapp_listener = true;
                        input.addEventListener('click', function(e) {
                            window.gptappLog('[gptapp] File input click detected');
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.screenshot) {
                                window.gptappLog('[gptapp] Sending upload-from-native message to native');
                                window.webkit.messageHandlers.screenshot.postMessage('upload-from-native');
                                e.preventDefault();
                                e.stopPropagation();
                            } else {
                                window.gptappLog('[gptapp] No native handler, allowing normal upload');
                            }
                        }, true);
                        window.gptappLog('[gptapp] MutationObserver registered file input for click interception');
                    }
                });
            });
            observer.observe(document.body, { childList: true, subtree: true });
            // Initial scan
            const event = new Event('gptapp-scan');
            document.body.dispatchEvent(event);
            window.gptappLog('[gptapp] MutationObserver injected and observing for file inputs (setup)');
        })();
        """
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                NSLog("[gptapp] Failed to inject MutationObserver JS on setup: \(error.localizedDescription)")
            } else {
                NSLog("[gptapp] MutationObserver JS injected successfully on setup")
            }
        }
    }
    
    // WKUIDelegate file upload logic
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.begin { result in
            if result == .OK {
                completionHandler(panel.urls)
            } else {
                completionHandler(nil)
            }
        }
    }

    // Also inject on navigation finish as a backup
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("[gptapp] didFinish navigation: injecting MutationObserver JS into chat.openai.com")
        injectMutationObserver()
    }

    // Listen for JS message and upload screenshot if available
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "gptapplog", let log = message.body as? String {
            NSLog("%@", log)
            return
        }
        NSLog("[gptapp] Received JS message: \(message.body)")
        guard message.name == "screenshot", let body = message.body as? String, body == "upload-from-native" else {
            NSLog("[gptapp] Ignored JS message: not 'upload-from-native'")
            return
        }
        guard let screenshot = appCoordinator?.screenshot else {
            NSLog("[gptapp] No screenshot available in AppCoordinator, letting user upload manually")
            return
        }
        NSLog("[gptapp] Screenshot found in AppCoordinator, preparing to upload")
        // Convert CGImage to PNG Data
        let bitmapRep = NSBitmapImageRep(cgImage: screenshot)
        guard let imageData = bitmapRep.representation(using: .png, properties: [:]) else {
            NSLog("[gptapp] Failed to convert screenshot to PNG data")
            return
        }
        // Write to temp file
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("gptapp_screenshot.png")
        do {
            try imageData.write(to: tempURL)
            NSLog("[gptapp] Screenshot written to temp file: \(tempURL.path)")
        } catch {
            NSLog("[gptapp] Failed to write screenshot to temp file: \(error)")
            return
        }
        // Use JavaScript to set the file input's files property
        let js = """
        (function() {
            const fileInput = document.querySelector('input[type=\"file\"]');
            if (!fileInput) {
                window.gptappLog('[gptapp] No file input found for upload');
                return;
            }
            // Native code will trigger the file picker with the temp file
            // This is a placeholder: actual file upload may require more integration
        })();
        """
        webView?.evaluateJavaScript(js) { result, error in
            if let error = error {
                NSLog("[gptapp] Failed to inject file upload JS: \(error.localizedDescription)")
            } else {
                NSLog("[gptapp] File upload JS injected successfully")
            }
        }
        // Optionally, trigger the file picker with the temp file (native integration required)
    }
} 