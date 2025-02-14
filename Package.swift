// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "spm-klat-uikit-framework",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "spm-klat-uikit-framework",
            targets: ["spm-klat-uikit-target",]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            name: "spm-talkplus-framework",
            url: "https://github.com/adxcorp/talkplus-ios-release",
            from: "1.0.1"
        )
    ],
    targets: [
        .binaryTarget(
            name: "klat-uikit-binary",
            path: "ios/KlatUIKit.xcframework"
        ),
        .target(
            name: "spm-klat-uikit-target",
            dependencies: [
                .target(name: "klat-uikit-binary"),
                .product(name: "spm-talkplus-framework", package: "spm-talkplus-framework")
            ],
            path: "Framework/Dependency",
            exclude: ["../../Sources", "../../KlatUIKitDemo"]
        ),
    ]
)
