import SwiftUI
import UIKit

/// Shows a stored item photo, decoding it off the main thread.
struct ItemImage: View {
    let url: URL
    var contentMode: ContentMode = .fill

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ProgressView()
            }
        }
        .task(id: url) {
            image = await Self.load(url)
        }
    }

    private static func load(_ url: URL) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            UIImage(contentsOfFile: url.path)?.preparingForDisplay()
        }.value
    }
}
