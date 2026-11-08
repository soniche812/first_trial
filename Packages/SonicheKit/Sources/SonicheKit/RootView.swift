import SwiftUI

/// The first screen of the app. A placeholder until real features land.
public struct RootView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tshirt")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.tint)
            Text(AppInfo.displayName)
                .font(.largeTitle.weight(.semibold))
                .tracking(4)
            Text(AppInfo.tagline)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    RootView()
}
