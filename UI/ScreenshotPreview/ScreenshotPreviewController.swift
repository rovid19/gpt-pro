import Cocoa
import SwiftUI

extension NSPasteboard.PasteboardType {
    static let jpeg = NSPasteboard.PasteboardType("public.jpeg")
}

class DraggableImageView: NSImageView {
    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect]
        let area = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(area)
        self.trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.push()
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.pop()
    }

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

 func showPreview(from image: CGImage, in homeView: NSWindow) {
    NSLog("[gptapp] [Preview] showPreview called")
    removePreview()

    NSLog("[gptapp] [Preview] homeView is type: %@", String(describing: type(of: homeView)))
    if let homeWindow = homeView as? HomeWindow {
        NSLog("[gptapp] [Preview] homeView is HomeWindow")
        if let homeView = homeWindow.homeView {
            NSLog("[gptapp] [Preview] homeWindow.homeView exists")
            if let recents = homeView.recentScreenshotsView {
                NSLog("[gptapp] [Preview] homeView.recentScreenshotsView exists, appending screenshot")
                let containerWidth = recents.bounds.width - 2 * recents.padding
                let aspectRatio = CGFloat(image.height) / CGFloat(image.width)
                let imageView = DraggableImageView()
                imageView.image = NSImage(cgImage: image, size: NSSize(width: containerWidth, height: containerWidth * aspectRatio))
                imageView.imageScaling = .scaleProportionallyUpOrDown
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalToConstant: containerWidth),
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: aspectRatio)
                ])
                recents.appendScreenshot(imageView)
            } else {
                NSLog("[gptapp] [Preview] homeView.recentScreenshotsView is nil")
            }
        } else {
            NSLog("[gptapp] [Preview] homeWindow.homeView is nil")
        }
    } else {
        NSLog("[gptapp] [Preview] homeView is not HomeWindow")
    }
}

    func removePreview() {
        previewImageView?.removeFromSuperview()
        previewImageView = nil
    }
} 
