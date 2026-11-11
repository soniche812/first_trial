import XCTest

/// End-to-end checks of the wardrobe screen, run on the iPhone simulator.
final class WardrobeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchWithSampleWardrobe() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--sample-wardrobe"]
        app.launch()
        return app
    }

    private func attachScreenshot(_ app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testWardrobeScrollsToLastCategory() {
        let app = launchWithSampleWardrobe()
        let grid = app.scrollViews["wardrobe-grid"]
        XCTAssertTrue(grid.waitForExistence(timeout: 15))
        attachScreenshot(app, named: "wardrobe-top")

        let lastHeader = app.descendants(matching: .any)["category-header-accessory"]
        XCTAssertFalse(lastHeader.exists && lastHeader.isHittable,
                       "Sample content should be taller than the screen")

        for _ in 0..<8 where !(lastHeader.exists && lastHeader.isHittable) {
            grid.swipeUp()
        }
        attachScreenshot(app, named: "wardrobe-scrolled")
        XCTAssertTrue(lastHeader.exists && lastHeader.isHittable,
                      "Scrolling should reveal the Accessories section")
    }

    func testOpeningAnItemShowsItsDetails() {
        let app = launchWithSampleWardrobe()
        let firstItem = app.buttons["Sample top 1"]
        XCTAssertTrue(firstItem.waitForExistence(timeout: 15))
        firstItem.tap()

        XCTAssertTrue(app.navigationBars["Sample top 1"].waitForExistence(timeout: 5))
        attachScreenshot(app, named: "item-detail")

        app.buttons["Delete"].tap()
        attachScreenshot(app, named: "delete-confirmation")
        XCTAssertTrue(app.staticTexts["This item will be removed from your wardrobe."].waitForExistence(timeout: 5))
    }
}
