import Foundation
import UIKit

extension WardrobeStore {
    /// Launch argument that starts the app with sample items in a temporary folder,
    /// leaving the real wardrobe untouched. Used by UI tests and for demos.
    public static let sampleWardrobeLaunchArgument = "--sample-wardrobe"

    /// The store for this launch: sample items when the launch argument is present,
    /// otherwise the user's real wardrobe.
    public static func makeForCurrentLaunch() -> WardrobeStore {
        if ProcessInfo.processInfo.arguments.contains(sampleWardrobeLaunchArgument) {
            return sample()
        }
        return makeDefault()
    }

    /// A temporary store with plain colored portrait images in every category.
    static func sample(itemsPerCategory: Int = 3) -> WardrobeStore {
        let store = temporary()
        let colors: [UIColor] = [.systemTeal, .systemOrange, .systemIndigo, .systemPink, .systemBrown, .systemGreen]
        for (index, category) in ClothingCategory.allCases.enumerated() {
            let color = colors[index % colors.count]
            for number in 1...max(itemsPerCategory, 1) {
                guard let data = ImageProcessing.jpegData(from: portraitImage(color: color)) else { continue }
                try? store.add(
                    imageData: data,
                    name: "Sample \(category.singularName.lowercased()) \(number)",
                    category: category
                )
            }
        }
        return store
    }

    private static func portraitImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 300, height: 400)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.white.withAlphaComponent(0.35).setFill()
            context.fill(CGRect(x: 0, y: size.height * 0.4, width: size.width, height: size.height * 0.2))
        }
    }
}
