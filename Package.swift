// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
    name: "JanitorKit",
    
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "JanitorKit",
            targets: ["JanitorKit"]),
    ],
    
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "BasicMathTools", url: "https://github.com/RougeWare/Swift-Basic-Math-Tools.git", from: "1.3.0"),
        .package(name: "CollectionTools", url: "https://github.com/RougeWare/Swift-Collection-Tools.git", from: "3.0.0"),
        .package(name: "FunctionTools", url: "https://github.com/RougeWare/Swift-Function-Tools", from: "1.2.0"),
        .package(name: "Introspection", url: "https://github.com/RougeWare/Swift-Introspection.git", from: "1.2.0"),
        .package(name: "PropertyWrapperProtocol", url: "https://github.com/RougeWare/Swift-PropertyWrapper-Protocol.git", from: "2.0.0"),
//        .package(name: "", url: "https://github.com/RougeWare/Swift-Lazy-Patterns.git", from: "4.0.0"),
//        .package(name: "", url: "https://github.com/RougeWare/Swift-Safe-Pointer.git", from: "2.0.0"),
//        .package(name: "", url: "https://github.com/RougeWare/Swift-Cross-Kit-Types.git", from: "1.0.0"),
//        .package(name: "", url: "https://github.com/RougeWare/Swift-Rectangle-Tools.git", from: "2.5.0"),
//        .package(name: "", url: "https://github.com/KyLeggiero/Swift-Drawing-Tools.git", from: "1.1.1"),
//        .package(name: "", url: "https://github.com/RougeWare/AttributedStringBuilder.git", .branch("develop")),
//        .package(name: "", url: "https://github.com/RougeWare/Swift-TODO.git", from: "1.1.0"),
//        .package(name: "", url: "https://github.com/RougeWare/Swift-Atomic.git", from: "0.0.0"),
        .package(name: "RangeTools", url: "https://github.com/RougeWare/Swift-Range-Tools.git", from: "1.2.1"),
        .package(name: "SafeCollectionAccess", url: "https://github.com/RougeWare/Swift-Safe-Collection-Access.git", from: "2.2.2"),
//        .package(name: "", name: "SimpleLogging", url: "https://github.com/RougeWare/Swift-Simple-Logging.git", .upToNextMinor(from: "0.4.4")),
        .package(name: "SimpleLogging", url: "https://github.com/RougeWare/Swift-Simple-Logging.git", branch: "feature/New-LogChannel-Architecture"),
        .package(name: "SwiftyUserDefaults", url: "https://github.com/sunshinejr/SwiftyUserDefaults.git", from: "5.3.0"),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "JanitorKit",
            dependencies: [
                "BasicMathTools",
                "CollectionTools",
                "FunctionTools",
                "Introspection",
                "PropertyWrapperProtocol",
                "RangeTools",
                "SafeCollectionAccess",
                "SimpleLogging",
                "SwiftyUserDefaults",
            ]),
        .testTarget(
            name: "JanitorKitTests",
            dependencies: ["JanitorKit"]),
    ]
)
