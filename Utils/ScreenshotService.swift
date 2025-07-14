//
//  ScreenshotService.swift
//  gpt-pro-app
//
//  Created by Roberto Vidovic on 10.07.2025..
//

import Foundation
import ScreenCaptureKit
import Cocoa

class ScreenshotService: NSObject, SCStreamOutput {
    private var onCaptured: ((CGImage) -> Void)?
    private var stream: SCStream?

    func captureOnce(completion: @escaping (CGImage?) -> Void) {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                guard let display = content.displays.first else {
                    NSLog("[ScreenshotService] ❌ No displays found")
                    completion(nil)
                    return
                }

                let config = SCStreamConfiguration()
                config.width = display.width
                config.height = display.height
                config.pixelFormat = kCVPixelFormatType_32BGRA

                let filter = SCContentFilter(display: display, excludingWindows: [])
                let stream = SCStream(filter: filter, configuration: config, delegate: nil)
                self.stream = stream

                self.onCaptured = { image in
                    completion(image)
                    Task { try? await stream.stopCapture() }
                }

                try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .main)
                try await stream.startCapture()
            } catch {
                NSLog("[ScreenshotService] ❌ Capture failed: \(error)")
                completion(nil)
            }
        }
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            onCaptured?(cgImage)
        }
    }
} 