import SwiftUI
import SonicheKit

@main
struct SonicheApp: App {
    @State private var wardrobe = WardrobeStore.makeForCurrentLaunch()

    var body: some Scene {
        WindowGroup {
            RootView(wardrobe: wardrobe)
        }
    }
}
