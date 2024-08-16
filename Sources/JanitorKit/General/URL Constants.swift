//
//  URL Constants.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-18.
//

import Foundation
import Cocoa



// MARK: User-space conveniences

public extension URL {
    
    /// The path to either the user’s or application’s home directory, depending on the platform.
    ///
    /// In iOS, the home directory is the application’s sandbox directory. In macOS, it’s the application’s sandbox directory, or the current user’s home directory if the application isn’t in a sandbox.
    @inlinable
    static var homeDirectory: URL {
        // Using `NSHomeDirectory()` instead of `FileManager.default.homeDirectoryForCurrentUser` because the NS one promises to be smart about app containers but the FileManager one doesn't
        return URL(fileURLWithPath: NSHomeDirectory())
    }
    
    
    static func relativeToUserHome(_ path: String) -> URL {
        return URL.User.relativeToHome(path: path)
    }
    
    
    
    enum User {
        // Empty on-purpose; all members are static
    }
}



extension URL.User: UrlNamespace {
    
    public static var domain: UrlNamespaceDomain {
        return .user
    }
    
    
    public static var home: URL {
        return .homeDirectory
    }
}



public protocol UrlNamespace {
    
    // MARK: Required
    
    static var home: URL { get }
    static var domain: UrlNamespaceDomain { get }
    
    
    // MARK: Optional
    
    static func relativeToHome(path: String) -> URL
    static func relativeToHome(pathComponents: [String]) -> URL
    static func relativeToHome(directory: Directory) -> URL?
    
    static var applications: URL? { get }
    static var library: URL? { get }
    static var desktop: URL? { get }
    static var downloads: URL? { get }
    
    
    
    typealias Domain = UrlNamespaceDomain
    typealias Directory = UrlNamespaceDirectory
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
public enum UrlNamespaceDirectory {
    
    /// The directory containing canonical applications installed within this namespace/domain
    case applications
    
    /// The directory containing technical/required files (caches, user data, ancillary executables, etc.) within this namespace/domain
    case library
    
    /// The directory the files within this namespace/domain which appear on the user's desktop
    case desktop
    
    /// The directory within this namespace/domain where downloaded files go by default
    case downloads
    
    
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
            
        case .documentDirectory,
             .trashDirectory:
            // Might do these in the future... 🤔
            return nil

        case .demoApplicationDirectory, .developerApplicationDirectory, .adminApplicationDirectory,
             
             .developerDirectory,
             .userDirectory,
             .documentationDirectory,
             .coreServiceDirectory,
             .autosavedInformationDirectory,
             .cachesDirectory,
             .applicationSupportDirectory,
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



public extension UrlNamespace {
    
    static var domainMask: FileManager.SearchPathDomainMask {
        return .init(domain)
    }
    
    
    static func searchPath(for directory: Directory, in domainMask: FileManager.SearchPathDomainMask, expandingTilde: Bool = true) -> [String] {
        NSSearchPathForDirectoriesInDomains(.init(directory), domainMask, expandingTilde)
    }
    

    static func relativeToHome(path: String) -> URL {
        return relativeToHome(pathComponents: (
            path
                .drop(while: { $0 == "/" })
                as NSString
            )
            .pathComponents
        )
    }
    
    
    static func relativeToHome(pathComponents: [String]) -> URL {
        return pathComponents
            .reduce(into: self.home) { (url, component) in
                url /= component
        }
    }
    
    
    static func relativeToHome(directory: Directory) -> URL? {
        let paths = searchPath(for: directory, in: domainMask)
        guard let firstPath = paths.first else {
            assertionFailure("No paths in \(directory) within \(domain)")
            
            return nil
        }
        return URL(fileURLWithPath: firstPath)
    }
    
    
    static var applications: URL? {
        return relativeToHome(directory: .applications)
    }
    
    
    static var library: URL? {
        return relativeToHome(directory: .library)
    }
    
    
    static var desktop: URL? {
        return relativeToHome(directory: .desktop)
    }
    
    
    static var downloads: URL? {
        return relativeToHome(directory: .downloads)
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
    init(_ directory: UrlNamespace.Directory) {
        switch directory {
        case .applications:
            self = .applicationDirectory
            
        case .library:
            self = .libraryDirectory
            
        case .desktop:
            self = .desktopDirectory
            
        case .downloads:
            self = .downloadsDirectory
        }
    }
}
