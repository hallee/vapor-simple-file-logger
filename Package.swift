// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SimpleFileLogger",
    products: [
        .library(name: "SimpleFileLogger", targets: ["SimpleFileLogger"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "SimpleFileLogger", dependencies: ["Vapor"])
    ]
)
