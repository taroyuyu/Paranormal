import Foundation
import CoreGraphics
import GPUImage
import Appkit

class ChamferTool {
    func preform(document: Document) {
        // TODO Update to the new document model.
        if let imageData = document.currentLayer?.imageData {
            let image = NSImage(data: imageData)
            // Apply the filter
            let chamfer = ChamferFilter()
            let resultImage = chamfer.imageByFilteringImage(image)
            document.currentLayer?.imageData = resultImage.TIFFRepresentation
        }
    }
}
