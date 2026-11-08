import UIKit

/// Prepares photos for storage.
public enum ImageProcessing {
    /// Returns JPEG data for `image`, scaled down so its longest side is at most
    /// `maxDimension` pixels. Smaller images keep their size. Orientation is applied.
    public static func jpegData(
        from image: UIImage,
        maxDimension: CGFloat = 1024,
        compressionQuality: CGFloat = 0.8
    ) -> Data? {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let longest = max(pixelWidth, pixelHeight)
        guard longest > 0 else { return nil }

        let factor = min(1, maxDimension / longest)
        let target = CGSize(width: (pixelWidth * factor).rounded(), height: (pixelHeight * factor).rounded())

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let resized = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: compressionQuality)
    }
}
