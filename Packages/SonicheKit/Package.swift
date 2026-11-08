// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SonicheKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SonicheKit", targets: ["SonicheKit"]),
    ],
    targets: [
        .target(name: "SonicheKit"),
        .testTarget(name: "SonicheKitTests", dependencies: ["SonicheKit"]),
    ]
)
