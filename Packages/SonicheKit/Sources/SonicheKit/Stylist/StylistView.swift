import SwiftUI

/// The stylist tab. A placeholder until AI outfit suggestions are built.
public struct StylistView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Your stylist is coming soon", systemImage: "sparkles")
            } description: {
                Text("SONICHE will suggest outfits from the clothes in your wardrobe.")
            }
            .navigationTitle("Stylist")
        }
    }
}

#Preview {
    StylistView()
}
