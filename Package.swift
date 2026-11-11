// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Gauge",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Gauge", targets: ["Gauge"])],
    dependencies: [
        .package(url: "https://github.com/jforaker/small-currents-design.git", exact: "1.7.2")
    ],
    targets: [
        .target(name: "GaugeCore"),
        .executableTarget(name: "Gauge", dependencies: ["GaugeCore", .product(name: "SmallCurrentsDesign", package: "small-currents-design")], resources: [.copy("Resources")]),
        .testTarget(name: "GaugeCoreTests", dependencies: ["GaugeCore"])
    ]
)
