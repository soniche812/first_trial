import SwiftUI
import SonicheKit

@main
struct SonicheApp: App {
    @State private var wardrobe = WardrobeStore.makeDefault()

    var body: some Scene {
        WindowGroup {
            RootView(wardrobe: wardrobe)
        }
    }
}
