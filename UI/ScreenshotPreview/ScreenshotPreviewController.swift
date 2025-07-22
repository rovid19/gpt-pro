import Cocoa
import SwiftUI

class ScreenshotPreviewController {
    private var previewImageView: DraggableImageView?

 func showPreview(from image: CGImage, in homeView: NSWindow) {
    removePreview()

    if let homeWindow = homeView as? HomeWindow {
        if let homeView = homeWindow.homeView {
            if let recents = homeView.recentScreenshotsView {
                let containerWidth = recents.bounds.width - 2 * recents.padding
                let aspectRatio = CGFloat(image.height) / CGFloat(image.width)
                let imageView = DraggableImageView(HomeWindow: homeWindow)
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
