// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftHandler",
    dependencies: [
        .package(url: "https://github.com/swift-server/http.git", .branch("develop")),
    ],
    targets: [
        .target(name: "SwiftHandler", dependencies: ["SwiftServerHTTP"]),
        .testTarget(name: "SwiftHandlerTests", dependencies: ["SwiftHandler"]),
    ]
)
