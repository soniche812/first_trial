import UIKit
import XCTest
@testable import SonicheKit

final class ImageProcessingTests: XCTestCase {
    private func makeImage(width: CGFloat, height: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

    private func pixelSize(of data: Data) throws -> CGSize {
        let image = try XCTUnwrap(UIImage(data: data))
        return CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
    }

    func testLargeImageIsScaledDownToMaxDimension() throws {
        let data = try XCTUnwrap(ImageProcessing.jpegData(from: makeImage(width: 3000, height: 2000), maxDimension: 1024))
        XCTAssertEqual(try pixelSize(of: data), CGSize(width: 1024, height: 683))
    }

    func testSmallImageKeepsItsSize() throws {
        let data = try XCTUnwrap(ImageProcessing.jpegData(from: makeImage(width: 400, height: 300), maxDimension: 1024))
        XCTAssertEqual(try pixelSize(of: data), CGSize(width: 400, height: 300))
    }
}
