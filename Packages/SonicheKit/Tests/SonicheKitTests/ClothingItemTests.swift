import XCTest
@testable import SonicheKit

final class ClothingItemTests: XCTestCase {
    private func item(name: String, category: ClothingCategory) -> ClothingItem {
        ClothingItem(id: UUID(), name: name, category: category, imageFileName: "x.jpg", createdAt: Date())
    }

    func testDisplayNameUsesNameWhenPresent() {
        XCTAssertEqual(item(name: "Red sneakers", category: .shoes).displayName, "Red sneakers")
    }

    func testDisplayNameFallsBackToCategory() {
        XCTAssertEqual(item(name: "", category: .dress).displayName, "Dress")
    }

    func testEveryCategoryHasNamesAndSymbol() {
        for category in ClothingCategory.allCases {
            XCTAssertFalse(category.displayName.isEmpty, "\(category)")
            XCTAssertFalse(category.singularName.isEmpty, "\(category)")
            XCTAssertFalse(category.symbolName.isEmpty, "\(category)")
        }
    }

    func testCategoryRawValuesAreStable() {
        // Raw values are stored on disk; changing them would break saved wardrobes.
        XCTAssertEqual(ClothingCategory.allCases.map(\.rawValue),
                       ["top", "bottom", "dress", "outerwear", "shoes", "accessory"])
    }
}
