// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Habit-Tracker",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Habit-Tracker",
            targets: ["Habit-Tracker"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Habit-Tracker",
            dependencies: []
        )
    ]
) 