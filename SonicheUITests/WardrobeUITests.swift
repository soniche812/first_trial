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

    func testWardrobeScrollsToLastItem() {
        let app = launchWithSampleWardrobe()
        let grid = app.scrollViews["wardrobe-grid"]
        XCTAssertTrue(grid.waitForExistence(timeout: 15))
        attachScreenshot(app, named: "wardrobe-top")

        // Newest first within each category, categories in declaration order.
        let firstItem = app.buttons["Sample top 3"]
        let lastItem = app.buttons["Sample accessory 1"]
        XCTAssertTrue(firstItem.waitForExistence(timeout: 5))
        print("WARDROBE-DEBUG window=\(app.windows.firstMatch.frame) grid=\(grid.frame) firstItem=\(firstItem.frame)")
        XCTAssertFalse(lastItem.exists && lastItem.isHittable,
                       "Sample content should be taller than the screen")

        let startY = firstItem.frame.minY
        grid.swipeUp()
        let movedY = firstItem.exists ? firstItem.frame.minY : -.greatestFiniteMagnitude
        print("WARDROBE-DEBUG after one swipe: firstItem.minY \(startY) -> \(movedY)")
        if movedY >= startY {
            print("WARDROBE-DEBUG hierarchy after one swipe:\n\(app.debugDescription)")
        }
        XCTAssertLessThan(movedY, startY, "A swipe up should move the content up")

        for _ in 0..<8 where !(lastItem.exists && lastItem.isHittable) {
            grid.swipeUp()
        }
        attachScreenshot(app, named: "wardrobe-scrolled")
        if !(lastItem.exists && lastItem.isHittable) {
            print("WARDROBE-DEBUG hierarchy after swipes:\n\(app.debugDescription)")
        }
        XCTAssertTrue(lastItem.exists && lastItem.isHittable,
                      "Scrolling should reach the last item")
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
