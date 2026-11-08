import XCTest
@testable import SonicheKit

final class AppInfoTests: XCTestCase {
    func testDisplayName() {
        XCTAssertEqual(AppInfo.displayName, "SONICHE")
    }

    func testTaglineIsNotEmpty() {
        XCTAssertFalse(AppInfo.tagline.isEmpty)
    }
}
