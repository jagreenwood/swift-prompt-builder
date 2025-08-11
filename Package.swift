// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "swift-prompt-builder",
    products: [
        .library(
            name: "PromptBuilder",
            targets: ["PromptBuilder"]),
    ],
    targets: [
        .target(
            name: "PromptBuilder"),
        .testTarget(
            name: "PromptBuilderTests",
            dependencies: ["PromptBuilder"]
        ),
    ]
)
