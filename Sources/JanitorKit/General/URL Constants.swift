//
//  URL Constants.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-18.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation
import Cocoa



// MARK: User-space conveniences

public extension URL {
    
    @inlinable
    static var userHome: URL {
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
        return .userHome
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



public enum UrlNamespaceDomain {
    case user
    case local
    case network
    case system
    
    
    init?(from mask: FileManager.SearchPathDomainMask) {
        if mask.contains(.userDomainMask) {
            self = .user
        }
        else if mask.contains(.localDomainMask) {
            self = .local
        }
        else if mask.contains(.networkDomainMask) {
            self = .network
        }
        else if mask.contains(.systemDomainMask) {
            self = .system
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



public enum UrlNamespaceDirectory {
    case applications
    case library
    case desktop
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
        let paths = NSSearchPathForDirectoriesInDomains(.init(directory), domainMask, /* expandingTilde: */ true)
        guard let firstPath = paths.first else {
            preconditionFailure("No paths in \(directory) within \(domain)")
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
