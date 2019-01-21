// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "vulkansample",
        products: [
            // Products define the executables and libraries produced by a package, and make them visible to other packages.
            .library(
                    name: "SwiftSDL2",
                    targets: ["SwiftSDL2"]),
            .executable(
                    name: "vulkansample",
                    targets: ["vulkansample"])
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            .package(url: "https://github.com/SwiftGL/Math.git", from: "2.0.0"),
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages which this package depends on.
            .systemLibrary(
                    name: "CSDL2",
                    pkgConfig: "sdl2",
                    providers: [
                        .brew(["sdl2"]),
                        .apt(["libsdl2-dev"])
                    ]
            ),
            .systemLibrary(
                    name: "CVulkan",
                    pkgConfig: "vulkan"
            ),
            .target(
                    name: "SwiftSDL2",
                    dependencies: [
                        "CSDL2",
                        "SwiftVulkan",
                        "SGLMath"
                    ]),
            .target(
                    name: "SwiftVulkan",
                    dependencies: [
                        "CVulkan"
                    ]),
            .target(
                    name: "vulkansample",
                    dependencies: [
                        "SwiftSDL2"
                    ]),
            .testTarget(
                    name: "vulkansampleTests",
                    dependencies: ["SwiftSDL2"]),
        ]
)
