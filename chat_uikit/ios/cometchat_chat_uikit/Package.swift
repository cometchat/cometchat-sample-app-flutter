// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "cometchat_chat_uikit",
  platforms: [
    .iOS("12.0")
  ],
  products: [
    .library(name: "cometchat-chat-uikit", targets: ["cometchat_chat_uikit"])
  ],
  dependencies: [
    // Supplied by the Flutter tool when it generates the app's SPM workspace.
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "cometchat_chat_uikit",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework")
      ]
    )
  ]
)
