import SwiftUI

/// The app's top-level screen: a tab bar with the wardrobe and the stylist.
public struct RootView: View {
    let wardrobe: WardrobeStore

    public init(wardrobe: WardrobeStore) {
        self.wardrobe = wardrobe
    }

    public var body: some View {
        TabView {
            WardrobeView(store: wardrobe)
                .tabItem { Label("Wardrobe", systemImage: "tshirt") }
            StylistView()
                .tabItem { Label("Stylist", systemImage: "sparkles") }
        }
    }
}

#Preview {
    RootView(wardrobe: .temporary())
}
