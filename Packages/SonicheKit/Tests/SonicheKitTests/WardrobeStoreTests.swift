import XCTest
@testable import SonicheKit

final class WardrobeStoreTests: XCTestCase {
    private var directory: URL!
    private let sampleImage = Data([0xFF, 0xD8, 0xFF, 0xD9])

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WardrobeStoreTests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func fixedClock(start: TimeInterval = 1_000) -> () -> Date {
        var time = start
        return {
            time += 1
            return Date(timeIntervalSinceReferenceDate: time)
        }
    }

    func testNewStoreIsEmpty() {
        let store = WardrobeStore(directory: directory)
        XCTAssertTrue(store.items.isEmpty)
        XCTAssertNil(store.loadIssue)
    }

    func testAddSavesItemAndPhoto() throws {
        let store = WardrobeStore(directory: directory, now: fixedClock())
        let item = try store.add(imageData: sampleImage, name: "  Blue shirt \n", category: .top)

        XCTAssertEqual(store.items, [item])
        XCTAssertEqual(item.name, "Blue shirt")
        XCTAssertEqual(item.category, .top)
        XCTAssertEqual(try Data(contentsOf: store.imageURL(for: item)), sampleImage)
    }

    func testItemsPersistAcrossStoreInstances() throws {
        let first = WardrobeStore(directory: directory, now: fixedClock())
        let jeans = try first.add(imageData: sampleImage, name: "Jeans", category: .bottom)
        let boots = try first.add(imageData: sampleImage, name: "Boots", category: .shoes)

        let second = WardrobeStore(directory: directory)
        XCTAssertEqual(second.items, [boots, jeans])
    }

    func testNewestItemsComeFirst() throws {
        let store = WardrobeStore(directory: directory, now: fixedClock())
        let older = try store.add(imageData: sampleImage, name: "Older", category: .top)
        let newer = try store.add(imageData: sampleImage, name: "Newer", category: .top)
        XCTAssertEqual(store.items, [newer, older])
    }

    func testDeleteRemovesItemAndPhoto() throws {
        let store = WardrobeStore(directory: directory, now: fixedClock())
        let keep = try store.add(imageData: sampleImage, name: "Keep", category: .dress)
        let remove = try store.add(imageData: sampleImage, name: "Remove", category: .dress)
        let removedPhoto = store.imageURL(for: remove)

        try store.delete(remove)

        XCTAssertEqual(store.items, [keep])
        XCTAssertFalse(FileManager.default.fileExists(atPath: removedPhoto.path))
        XCTAssertEqual(WardrobeStore(directory: directory).items, [keep])
    }

    func testItemsInCategoryFiltersByCategory() throws {
        let store = WardrobeStore(directory: directory, now: fixedClock())
        let scarf = try store.add(imageData: sampleImage, name: "Scarf", category: .accessory)
        try store.add(imageData: sampleImage, name: "Coat", category: .outerwear)

        XCTAssertEqual(store.items(in: .accessory), [scarf])
        XCTAssertTrue(store.items(in: .shoes).isEmpty)
    }

    func testSampleWardrobeFillsEveryCategory() {
        let store = WardrobeStore.sample(itemsPerCategory: 2)
        for category in ClothingCategory.allCases {
            XCTAssertEqual(store.items(in: category).count, 2, "\(category)")
        }
        for item in store.items {
            XCTAssertTrue(FileManager.default.fileExists(atPath: store.imageURL(for: item).path))
        }
    }

    func testUnreadableIndexIsKeptAsBackupAndReported() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let garbage = Data("not json".utf8)
        try garbage.write(to: directory.appendingPathComponent("wardrobe.json"))

        let store = WardrobeStore(directory: directory)

        XCTAssertTrue(store.items.isEmpty)
        XCTAssertNotNil(store.loadIssue)
        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        XCTAssertFalse(files.contains("wardrobe.json"))
        let backup = try XCTUnwrap(files.first { $0.hasPrefix("wardrobe-unreadable-") })
        XCTAssertEqual(try Data(contentsOf: directory.appendingPathComponent(backup)), garbage)

        store.acknowledgeLoadIssue()
        XCTAssertNil(store.loadIssue)
    }
}
