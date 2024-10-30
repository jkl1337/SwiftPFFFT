// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPFFFT",
    products: [
        .library(
            name: "PFFFT",
            targets: ["PFFFT", "PFFFTLib"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "PFFFTLib",
            publicHeadersPath: "include",
            cSettings: [
                .define("PFFFT_SCALVEC_ENABLED", to: "1"),
                .define("_USE_MATH_DEFINES"),
                .define("NDEBUG"),
                .unsafeFlags(["-O3"]),
            ]
        ),
        .target(
            name: "PFFFT",
            dependencies: ["PFFFTLib", .product(name: "Numerics", package: "swift-numerics")]
        ),
        .testTarget(
            name: "PFFFTTests",
            dependencies: ["PFFFT"]
        ),
    ],
    cLanguageStandard: .c99
)
