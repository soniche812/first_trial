/// The kinds of clothing a wardrobe item can be.
public enum ClothingCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case top
    case bottom
    case dress
    case outerwear
    case shoes
    case accessory

    public var id: String { rawValue }

    /// Plural name, used for section headers.
    public var displayName: String {
        switch self {
        case .top: "Tops"
        case .bottom: "Bottoms"
        case .dress: "Dresses"
        case .outerwear: "Outerwear"
        case .shoes: "Shoes"
        case .accessory: "Accessories"
        }
    }

    /// Singular name, used for a single item without its own name.
    public var singularName: String {
        switch self {
        case .top: "Top"
        case .bottom: "Bottom"
        case .dress: "Dress"
        case .outerwear: "Outerwear"
        case .shoes: "Shoes"
        case .accessory: "Accessory"
        }
    }

    /// SF Symbol shown next to the category.
    public var symbolName: String {
        switch self {
        case .top: "tshirt"
        case .bottom: "rectangle.split.1x2"
        case .dress: "figure.stand.dress"
        case .outerwear: "wind"
        case .shoes: "shoe"
        case .accessory: "handbag"
        }
    }
}
