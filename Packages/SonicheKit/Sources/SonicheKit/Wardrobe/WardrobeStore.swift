import Foundation
import Observation

/// Errors raised while adding items to the wardrobe.
public enum WardrobeError: LocalizedError {
    case imageEncodingFailed

    public var errorDescription: String? {
        switch self {
        case .imageEncodingFailed: "The photo could not be prepared for saving."
        }
    }
}

/// Keeps the wardrobe on the device: a JSON index plus one JPEG file per item.
///
/// Layout inside `directory`:
/// - `wardrobe.json`: the list of items
/// - `Images/<item id>.jpg`: each item's photo
@Observable
public final class WardrobeStore {
    /// All items, newest first.
    public private(set) var items: [ClothingItem] = []

    /// Set when the saved wardrobe existed but could not be read.
    public private(set) var loadIssue: String?

    private let directory: URL
    private let now: () -> Date

    private var indexURL: URL { directory.appendingPathComponent("wardrobe.json") }
    private var imagesDirectory: URL { directory.appendingPathComponent("Images", isDirectory: true) }

    public init(directory: URL, now: @escaping () -> Date = Date.init) {
        self.directory = directory
        self.now = now
        load()
    }

    /// The store used by the app, kept in Application Support.
    public static func makeDefault() -> WardrobeStore {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return WardrobeStore(directory: base.appendingPathComponent("Wardrobe", isDirectory: true))
    }

    /// A throwaway store in a temporary folder, for SwiftUI previews.
    static func temporary() -> WardrobeStore {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("WardrobePreview-\(UUID().uuidString)", isDirectory: true)
        return WardrobeStore(directory: folder)
    }

    public func imageURL(for item: ClothingItem) -> URL {
        imagesDirectory.appendingPathComponent(item.imageFileName)
    }

    public func items(in category: ClothingCategory) -> [ClothingItem] {
        items.filter { $0.category == category }
    }

    /// Saves a new item with its photo. The name is trimmed and may be empty.
    @discardableResult
    public func add(imageData: Data, name: String, category: ClothingCategory) throws -> ClothingItem {
        try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        let id = UUID()
        let item = ClothingItem(
            id: id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            imageFileName: "\(id.uuidString).jpg",
            createdAt: now()
        )
        let photoURL = imageURL(for: item)
        try imageData.write(to: photoURL, options: .atomic)

        var updated = items
        updated.append(item)
        updated.sort(by: Self.newestFirst)
        do {
            try save(updated)
        } catch {
            try? FileManager.default.removeItem(at: photoURL)
            throw error
        }
        items = updated
        return item
    }

    /// Removes an item and its photo.
    public func delete(_ item: ClothingItem) throws {
        let updated = items.filter { $0.id != item.id }
        try save(updated)
        items = updated
        try? FileManager.default.removeItem(at: imageURL(for: item))
    }

    /// Clears `loadIssue` once the user has been told about it.
    public func acknowledgeLoadIssue() {
        loadIssue = nil
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: indexURL.path) else { return }
        do {
            let data = try Data(contentsOf: indexURL)
            items = try JSONDecoder().decode([ClothingItem].self, from: data).sorted(by: Self.newestFirst)
        } catch {
            // Keep the unreadable file so a later save does not destroy the user's data.
            let backupName = "wardrobe-unreadable-\(Int(now().timeIntervalSince1970)).json"
            try? FileManager.default.moveItem(at: indexURL, to: directory.appendingPathComponent(backupName))
            loadIssue = "Your saved wardrobe could not be read, so SONICHE started a new one. The old data was kept as \(backupName)."
        }
    }

    private func save(_ items: [ClothingItem]) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(items).write(to: indexURL, options: .atomic)
    }

    private static func newestFirst(_ lhs: ClothingItem, _ rhs: ClothingItem) -> Bool {
        lhs.createdAt > rhs.createdAt
    }
}
