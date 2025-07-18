import Cocoa
import SwiftUI

extension NSPasteboard.PasteboardType {
    static let jpeg = NSPasteboard.PasteboardType("public.jpeg")
}

class DraggableImageView: NSImageView {
    override func mouseDown(with event: NSEvent) {
        guard let image = self.image else { return }
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileURL = tempDir.appendingPathComponent("dragged-image-\(UUID().uuidString).png")
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: fileURL)
        } else {
            return
        }
        let draggingItem = NSDraggingItem(pasteboardWriter: fileURL as NSURL)
        draggingItem.setDraggingFrame(self.bounds, contents: image)
        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }
}

extension DraggableImageView: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
}

class ScreenshotPreviewController {
    private var previewImageView: DraggableImageView?

    /// Shows the preview and returns the frame used for the preview image view.
    /// Appends the preview to the given HomeView's NSView representation.

 func showPreview(from image: CGImage, in homeView: NSView) {
    NSLog("[gptapp] [Preview] showPreview called")
    removePreview()

    homeView.wantsLayer = true
    let previewWidth: CGFloat = 200
    let aspectRatio = CGFloat(image.height) / CGFloat(image.width)
    let previewHeight = previewWidth * aspectRatio

    let homeFrame = homeView.frame
    NSLog("[gptapp] homeView frame: \(homeFrame)")
    NSLog("[gptapp] window: \(homeView.window?.description ?? "nil")")

    let centerX = homeFrame.width / 2 - previewWidth / 2
    let centerY = homeFrame.height / 2 - previewHeight / 2
    let previewFrame = CGRect(x: centerX, y: centerY, width: previewWidth, height: previewHeight)

    let nsImage = NSImage(cgImage: image, size: NSSize(width: previewWidth, height: previewHeight))
    NSLog("[gptapp] nsImage size: \(nsImage.size.width) x \(nsImage.size.height)")

    let imageView = DraggableImageView(frame: previewFrame)
    imageView.image = nsImage
    imageView.imageScaling = .scaleProportionallyUpOrDown
    imageView.wantsLayer = true
    imageView.layerContentsRedrawPolicy = .onSetNeedsDisplay
    imageView.layer?.contents = nsImage
    imageView.layer?.cornerRadius = 8
    imageView.layer?.borderWidth = 1
    imageView.layer?.borderColor = NSColor.white.withAlphaComponent(0.4).cgColor
    imageView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
    imageView.layer?.zPosition = 999

    homeView.addSubview(imageView)
    imageView.needsDisplay = true
    homeView.displayIfNeeded()
    
    self.previewImageView = imageView
}

    func removePreview() {
        previewImageView?.removeFromSuperview()
        previewImageView = nil
    }
} 
