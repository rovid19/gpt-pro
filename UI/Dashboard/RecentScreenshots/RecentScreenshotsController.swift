import Cocoa
import SwiftUI

class RecentScreenshotsController {
    var previewImageView: DraggableImageView?
    var recentScreenshotsView: RecentScreenshotsView

    init() {
        self.recentScreenshotsView = RecentScreenshotsView()
    }

    func showPreview(from image: CGImage, in homeWindow: NSWindow) {
        NSLog("[gptapp] [ScreenshotPreviewController] showPreview")
        NSLog("[gptapp] [ScreenshotPreviewController] homeWindow \(homeWindow)")
        
        guard let homeWindowView = homeWindow as? HomeWindowView else {
            NSLog("[gptapp] [Preview] homeWindow is not HomeWindowView")
            return
        }
        
        let homeViewController = homeWindowView.homeViewController
        
        let recentScreenshotsView = homeViewController.recentScreenshotsController.recentScreenshotsView
        
        let containerWidth = recentScreenshotsView.bounds.width - 2 * recentScreenshotsView.padding
        let aspectRatio = CGFloat(image.height) / CGFloat(image.width)
        
        let imageView = DraggableImageView(HomeWindowView: homeWindowView)
        imageView.image = NSImage(cgImage: image, size: NSSize(width: containerWidth, height: containerWidth * aspectRatio))
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: containerWidth),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: aspectRatio),
        ])
        
        recentScreenshotsView.appendScreenshot(imageView)
        NSLog("[gptapp] [Preview] Screenshot preview added successfully")
    }

    func removePreview() {
        previewImageView?.removeFromSuperview()
        previewImageView = nil
    }
}
