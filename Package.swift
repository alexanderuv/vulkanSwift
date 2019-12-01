// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "SwiftVulkanSample",
        products: [
            // Products define the executables and libraries produced by a package, and make them visible to other packages.
            .executable(
                    name: "SwiftVulkanSample",
                    targets: ["SwiftVulkanSample"])
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            .package(url: "https://github.com/alexanderuv/SDL", .branch("master")),
        ],
        targets: [
            .systemLibrary(
                    name: "CVulkan",
                    pkgConfig: "vulkan"
            ),
            .systemLibrary(
                    name: "SwiftVulkanUnions"),
            .target(
                    name: "SwiftVulkan",
                    dependencies: [
                        "CVulkan",
                        "SwiftVulkanUnions"
                    ]),
            .target(
                    name: "SwiftVulkanSample",
                    dependencies: [
                        "SDL",
                        "SwiftVulkan"
                    ]),
            .testTarget(
                    name: "SwiftVulkanSampleTests",
                    dependencies: ["SDL"])
        ]
)
