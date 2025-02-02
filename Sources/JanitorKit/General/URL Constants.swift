//
//  URL Constants.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-18.
//

import Foundation
import Cocoa

import Introspection
import SimpleLogging



// MARK: Domain conveniences

public extension URL {
    
    /// The path to either the user’s or application’s home directory, depending on the platform.
    ///
    /// In iOS, the home directory is the application’s sandbox directory. In macOS, it’s the application’s sandbox directory, or the current user’s home directory if the application isn’t in a sandbox.
    @inlinable
    static var homeDirectory: URL {
        // Using `NSHomeDirectory()` instead of `FileManager.default.homeDirectoryForCurrentUser` because the NS one promises to be smart about app containers but the FileManager one doesn't
        return URL(fileURLWithPath: NSHomeDirectory())
    }
    
    /// The lowest-level directory on this machine. All other directories are children of this one
    static let rootDirectory: URL = {
        // Is there a semantic way we can do this?
        .init(_filePath: "/")
    }()
    
    /// The directory containing system files (like `/System`)
    static let systemDirectory: Self = {
        FileManager.default.urls(for: .libraryDirectory, in: .systemDomainMask)
            .first?.deletingLastPathComponent()
            ?? URL(_filePath: "/System")
    }()
    
    
    /// The Application Support subdirectory for this app (like `~/Library/Application Support/com.example.MyApp/`)
    static let myApplicationSupport: Self = {
        (URL.User.relativeToSubroot(directory: .applicationSupport)
         ?? (URL.homeDirectory / "Application Support"))
        / Introspection.bundleId
    }()
    
    
    static func relativeToUserHome(_ path: String) -> URL {
        return URL.User.relativeToSubroot(path: path)
    }
    
    
    
    enum User {
        // Empty on-purpose; all members are static
    }
    
    
    
    enum Local {
        // Empty on-purpose; all members are static
    }
    
    
    
    enum System {
        // Empty on-purpose; all members are static
    }
}



extension URL.User: UrlNamespace {
    
    public static var domain: UrlNamespaceDomain {
        return .user
    }
    
    
//    public static var home: URL? {
//        return .homeDirectory
//    }
    
    
    @inline(__always)
    public static var subroot: URL {
        return .userDirectory
    }
}



extension URL.Local: UrlNamespace {
    
    public static var domain: UrlNamespaceDomain {
        .local
    }
    
    
//    public static var home: URL? { nil }
    
    
    @inline(__always)
    public static var subroot: URL {
        .rootDirectory
    }
}



extension URL.System: UrlNamespace {
    
    public static var domain: UrlNamespaceDomain {
        .system
    }
    
    
//    public static var home: URL? { nil }
    
    
    @inline(__always)
    public static var subroot: URL {
        .systemDirectory
    }
}



public protocol UrlNamespace {
    
    // MARK: Required
    
    /// The directory which defines this namespace
    static var subroot: URL { get }
    
//    /// The home directory in this namespace. Not all domains have home directories
//    static var home: URL? { get }
    
    /// This namespace's semantic domain
    static var domain: UrlNamespaceDomain { get }
    
    
    // MARK: Optional
    
    static func relativeToSubroot(path: String) -> URL
    static func relativeToSubroot(pathComponents: [String]) -> URL
    static func relativeToSubroot(directory: SemanticDirectory) -> URL?
    
    static var applications: URL? { get }
    static var library: URL? { get }
    static var desktop: URL? { get }
    static var downloads: URL? { get }
    
    
    // MARK: / Operators
    
    static func / (lhs: Self.Type, rhs: SemanticDirectory) -> URL?
    
    
    
    typealias Domain = UrlNamespaceDomain
    typealias SemanticDirectory = UrlNamespaceDirectory
}



/// A domain namespace for filesystem locations
public enum UrlNamespaceDomain {
    /// The domain of the currently logged-in user (or the container of an app acting as the user's agent); the user’s home directory—the place to install user’s personal items (~).
    case user
    
    /// The domain of all users of this machine; the place to install items available to everyone on this machine.
    case local
    
    /// The domain of this machine's operating system; a directory for system files provided by Apple (/System) .
    case system
    
    /// **RARE:** The domain of the network this machine is on; The place to install items available on the network (/Network).
    case network
    
    
    /// Finds the most local domain represented in the given domain mask.
    ///
    /// This searches in the order of this enum, from most to least local: User, then Local, then System, then Network.
    /// If the given mask contains more than one of these (for example, ``allDomainsMask``), the most-local one is selected
    ///
    /// - Parameter mask: The search path domain mask to parse into namespace domains
    init?(from mask: FileManager.SearchPathDomainMask) {
        if mask.contains(.userDomainMask) {
            self = .user
        }
        else if mask.contains(.localDomainMask) {
            self = .local
        }
        else if mask.contains(.systemDomainMask) {
            self = .system
        }
        else if mask.contains(.networkDomainMask) {
            self = .network
        }
        else {
            return nil
        }
    }
}



extension UrlNamespaceDomain: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .user:
            return "User"
            
        case .local:
            return "Local"
            
        case .network:
            return "Network"
            
        case .system:
            return "System"
        }
    }
}



/// A directory within a namespace/domain
public enum UrlNamespaceDirectory: CaseIterable {
    
    case fileManager(FileManagerSearchPathDirectory)
    case generic(GenericDirectory)
    // IMPORTANT: If you add another case, be sure to add it to `allCases` as well
    
    
    init?(from searchPathDirectory: FileManager.SearchPathDirectory) {
        if let analog = FileManagerSearchPathDirectory(from: searchPathDirectory) {
            self = .fileManager(analog)
        }
        else {
            return nil
        }
    }
    
    
//    static let root = generic(.root)
    static let all = generic(.all)
    
    static let applications = fileManager(.applications)
    static let desktop = fileManager(.desktop)
    static let downloads = fileManager(.downloads)
    static let library = fileManager(.library)
    static let users = fileManager(.users)
    static let applicationSupport = fileManager(.applicationSupport)
    
    
    
    public static var allCases: [Self] =
        FileManagerSearchPathDirectory.allCases.map(Self.fileManager)
        + GenericDirectory.allCases.map(Self.generic)
    
    
    
    public enum FileManagerSearchPathDirectory: CaseIterable {
        
        /// The directory containing canonical applications installed within this namespace/domain (like `/Applications/`)
        case applications
        
        /// The directory containing technical/required files (caches, user data, ancillary executables, etc.) within this namespace/domain (like `/Library/`)
        case library
        
        /// The directory the files within this namespace/domain which appear on the user's desktop (like `~/Desktop/`)
        case desktop
        
        /// The directory within this namespace/domain where downloaded files go by default (like `~/Downloads/`)
        case downloads
        
        /// The directory containing user homes (like `/Users/`)
        case users
        
        /// The directory containing all apps' save data (like `~/Library/Application Support/`)
        case applicationSupport
        
        
        
        
        
        init?(from searchPathDirectory: FileManager.SearchPathDirectory) {
            switch searchPathDirectory {
            case .applicationDirectory:
                self = .applications
                
            case .libraryDirectory:
                self = .library
                
                
            case .desktopDirectory:
                self = .desktop
                
            case .downloadsDirectory:
                self = .downloads
                
            case .userDirectory:
                self = .users
                
            case .documentDirectory,
                    .trashDirectory:
                // Might do these in the future... 🤔
                return nil
                
            case .applicationSupportDirectory:
                self = .applicationSupport
                
            case .demoApplicationDirectory, .developerApplicationDirectory, .adminApplicationDirectory,
                
                    .developerDirectory,
                    .documentationDirectory,
                    .coreServiceDirectory,
                    .autosavedInformationDirectory,
                    .cachesDirectory,
                    .inputMethodsDirectory,
                    .moviesDirectory,
                    .musicDirectory,
                    .picturesDirectory,
                    .printerDescriptionDirectory,
                    .sharedPublicDirectory,
                    .preferencePanesDirectory,
                    .applicationScriptsDirectory,
                    .itemReplacementDirectory,
                
                    .allApplicationsDirectory,
                    .allLibrariesDirectory:
                
                // No current/prospective interest in using these
                fallthrough
                
            @unknown default:
                return nil
            }
        }
    }
    
    
    
    public enum GenericDirectory: CaseIterable {
        /// All top-level directories of a namespace/domain
        case all
    }
}



public extension UrlNamespace {
    
    static var domainMask: FileManager.SearchPathDomainMask {
        return .init(domain)
    }
    
    
    static func semanticDirectories(_ directory: SemanticDirectory, expandingTilde: Bool = true) -> [URL] {
        switch directory {
        case .fileManager(let directory):
            NSSearchPathForDirectoriesInDomains(.init(directory), .init(domain), expandingTilde)
                .map(URL.init(_filePath:))
            
        case .generic(.all):
            SemanticDirectory.allCases.flatMap { directory  in
                switch directory {
                case .fileManager(let fmDirectory):
                    NSSearchPathForDirectoriesInDomains(.init(fmDirectory), .init(domain), expandingTilde)
                        .map(URL.init(_filePath:))
                    
                case .generic(.all):
                    [URL]() // Let's not SO today
                }
            }
        }
    }
    

    static func relativeToSubroot(path: String) -> URL {
        relativeToSubroot(
            pathComponents:
                URL(_filePath: String(path
                    .drop(while: { $0 == "/" })))
                .pathComponents
        )
    }
    
    
    static func relativeToSubroot(pathComponents: [String]) -> URL {
        return pathComponents
            .reduce(into: subroot) { (url, component) in
                url /= component
            }
    }
    
    
    static func relativeToSubroot(directory: SemanticDirectory) -> URL? {
        let urls = semanticDirectories(directory)
        guard let firstUrl = urls.first else {
            assertionFailure("No paths in \(directory) within \(domain)")
            
            return nil
        }
        
        return firstUrl
    }
    
    
    static var applications: URL? {
        return relativeToSubroot(directory: .applications)
    }
    
    
    static var library: URL? {
        return relativeToSubroot(directory: .library)
    }
    
    
    static var desktop: URL? {
        return relativeToSubroot(directory: .desktop)
    }
    
    
    static var downloads: URL? {
        return relativeToSubroot(directory: .downloads)
    }
    
    
    static func / (lhs: Self.Type, rhs: SemanticDirectory) -> URL? {
        lhs.relativeToSubroot(directory: rhs)
    }
}



public extension FileManager.SearchPathDomainMask {
    init(_ domain: UrlNamespace.Domain) {
        switch domain {
        case .user:
            self = .userDomainMask
            
        case .local:
            self = .localDomainMask
            
        case .network:
            self = .networkDomainMask
            
        case .system:
            self = .systemDomainMask
        }
    }
}



public extension FileManager.SearchPathDirectory {
    init(_ directory: UrlNamespace.SemanticDirectory.FileManagerSearchPathDirectory) {
        switch directory {
        case .applications:
            self = .applicationDirectory
            
        case .library:
            self = .libraryDirectory
            
        case .desktop:
            self = .desktopDirectory
            
        case .downloads:
            self = .downloadsDirectory
            
        case .users:
            self = .userDirectory
            
        case .applicationSupport:
            self = .applicationSupportDirectory
        }
    }
}
