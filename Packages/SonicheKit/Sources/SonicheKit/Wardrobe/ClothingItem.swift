import Foundation

/// One piece of clothing in the user's wardrobe.
public struct ClothingItem: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var category: ClothingCategory
    /// File name of the item's photo inside the wardrobe's image folder.
    public let imageFileName: String
    public let createdAt: Date

    public init(id: UUID, name: String, category: ClothingCategory, imageFileName: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.category = category
        self.imageFileName = imageFileName
        self.createdAt = createdAt
    }

    /// The item's name, or its category when it has no name.
    public var displayName: String {
        name.isEmpty ? category.singularName : name
    }
}
