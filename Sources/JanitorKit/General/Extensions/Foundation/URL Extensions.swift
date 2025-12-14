//
//  URL Extensions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-08-03.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation

import SimpleLogging



// MARK: - Path properties

public extension URL {
    
    /// Determines whether this URL represents the root directory (`/`)
    var isRoot: Bool {
        URL.Local.subroot.actualPath == self.actualPath
    }
    
    
    /// If this URL points to a user home, this returns the semantic description of that.
    /// If it doesn't, this returns `nil`.
    var isUserHome: UserHome? {
        let actualPath = self.actualPath
        //                if self.standardizedFileURL == URL.userHomeDirectory.deletingLastPathComponent().standardizedFileURL {
        //                    // this is the root user home directory
        //                    return .userHome(user: .allUsers)
        //                }
        //                else {
        //                    self.pathComponents.suffix(startingFrom: { $0 == "Users" })
        //                }
        if URL.homeDirectory.actualPath == actualPath {
            return .currentUser
        }
        else if URL.User.subroot.actualPath == self.deletingLastPathComponent().actualPath {
            return .specific(accountName: self.lastPathComponent)
        }
        else if URL.User.subroot.actualPath == self.actualPath {
            return .allUsers
        }
        else {
            return .none
        }
    }
    
    
    /// Whether this is a system directory
    var isSystemDir: Bool {
        !isRoot
        && URL.System
            .semanticDirectories(.all)
            .lazy
            .map(\.actualPath)
            .contains(self.actualPath)
    }
    
    
    
    /// A kind of user home directory
    enum UserHome {
        
        // using `nil` is probably better
//        /// The directory is not a user home directory (although it may be within one) (like `/usr/bin/` or `/Users/ky/Desktop/`).
//        ///
//        /// This could also represent that this is not a directory at all (like `/usr/bin/zsh` or `/Users/ky/.zshrc`)
//        case notUserHome
        
        /// The home directory of the user currently logged in (`~/`)
        case currentUser
        
        /// The home directory of one specific user (like `/Users/ky/`)
        /// - Parameter accountName: The name of the account associated with this user home (like `"ky"`)
        case specific(accountName: String)
        
        /// The root user home directory (like `/Users/`), or a directory which contains it (like `/`)
        case allUsers
    }
}



// MARK: - Danger

public extension URL {
    
    var wouldBeDangerousToAutoDelete: Bool {
        switch autoDeleteDanger {
        case .none:
            return false
            
        case .root,
             .system,
             .userHome(user: _):
            return true
        }
    }
    
    
    var autoDeleteDanger: AutoDeleteDanger? {
        if isRoot {
            return .root
        }
        else if isSystemDir {
            return .system
        }
        else {
            guard let userHome = self.isUserHome else {
                return .none
            }
            
            switch userHome {
            case .currentUser,
                    .specific(accountName: _),
                    .allUsers:
                return .userHome(userHome)
            }
        }
    }
}



/// How dangerous would it be to set a program to automatically delete files in this directory?
public enum AutoDeleteDanger {
    
    // `nil` is probably better
//    /// A normal amount of danger, for typical user-scope files like screenshots and downloads.
//    ///
//    /// This represents the inherent danger in deleting any file, but nothing more than that.
//    case mundane
    
    /// The entire machine; the root directory. **This is the most dangerous possible directory to auto-delete from!**
    case root
    
    /// A system-controlled directory, like `/System` or `/bin`. **This is an extremely dangerous directory to auto-delete from!**
    case system
    
    /// An entire user home directory, like `/Users` or `/Users/ky`. **This is notably dangerous to auto-delete from!**
    case userHome(URL.UserHome)
}



public extension URL {
    
    /// Findsthe URLs of all child files in this directory
    ///
    /// - Returns: An array of all child files in this directory.
    ///            If this is not a directory, or if there are no files, this returns `[]`
    ///
    /// - Parameter fileManager:     _optional_ The file manager which will be used to fetch the contents of this directory. Defaults to `.standard`
    /// - Parameter behavior: _optional_ Iff `true`, hidden files will **not** be returned. Defaults to `true`.
    /// - Parameter skipDirectories: _optional_ Iff `true`
    func allChildren(using fileManager: FileManager = .default, behavior: AllChildrenBehavior = .default) -> [URL] {
        logEntry(); defer { logExit() }
        
        let allChildren = (try? fileManager.contentsOfDirectory(
                at: self,
                includingPropertiesForKeys: nil,
                options: behavior.contains(.includeHiddenFiles) ? [] : .skipsHiddenFiles))
            ?? []
        
        if behavior.contains(.includeDirectories) {
            log(debug: "Found \(allChildren.count) total files in this folder")
            return allChildren
        }
        else {
            let allChildren = allChildren.filter { !$0.hasDirectoryPath }
            log(debug: "Found \(allChildren.count) total files in this folder (excluded directories)")
            return allChildren
        }
    }
    
    
    
    /// How the `allChildren` function should behave
    struct AllChildrenBehavior: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        /// Hidden files should be included in the returned list of files
        public static let includeHiddenFiles = AllChildrenBehavior(rawValue: 1 << 0)
        
        /// Directories should be included in the returned list of files
        public static let includeDirectories = AllChildrenBehavior(rawValue: 1 << 1)
        
        /// The default behavior that `allChildren` uses
        public static let `default`: AllChildrenBehavior = []
    }
}



public extension URL {
    
    /// Returns this URL with some attributes annotated upon it
    var annotated: AnnotatedFile? {
        return AnnotatedFile(self)
    }
    
    
    /// Attempts to completely resolve this path
    var withActualPath: URL {
        self.resolvingSymlinksInPath().standardizedFileURL.absoluteURL
    }
    
    
    /// Attempts to completely resolve this path
    var actualPath: String {
        withActualPath.path
    }
    
    
    /// Attempts to find the date at which the file was added to the directory
    var dateAdded: Date? {
        if let metadataItemValue = MDItemCreateWithURL(kCFAllocatorDefault, (self as CFURL)) {
            return MDItemCopyAttribute(metadataItemValue, kMDItemDateAdded) as? Date
        }
        return nil
    }
    
    
    /// Attempts to find the age of this file based on the user's preference for which age to regard
    ///
    /// - Parameter attributes: _optional_ The attributes from which to draw the age calculation. Based on the user's
    ///                         preference on which age to regard, this might never be used.
    func userSpecifiedAge() -> Age? {
        return userSpecifiedAge(using: try attributes())
    }
    
    
    /// Attempts to find the age of this file based on the user's preference for which age to regard
    ///
    /// - Parameter attributes: _optional_ The attributes from which to draw the age calculation. Based on the user's
    ///                         preference on which age to regard, this might never be used.
    func userSpecifiedAge(using attributes: @autoclosure FileAttributesGetter) -> Age? {
        return self.age(by: UserPreferences.whichAgeToRegard, using: try attributes())
    }
    
    
    /// Attempts to find the age of this file based on the specified age to regard
    ///
    /// - Parameter whichAgeToRegard: Which of the several kinds of ages will be regarded as the age of the file
    /// - Parameter attributes:       _optional_ The attributes from which to draw the age calculation. Based on the
    ///                               user's preference on which age to regard, this might never be used.
    func age(by whichAgeToRegard: WhichAgeToRegard) -> Age? {
        return age(by: whichAgeToRegard, using: try attributes())
    }
    
    
    /// Attempts to find the age of this file based on the specified age to regard
    ///
    /// - Parameter whichAgeToRegard: Which of the several kinds of ages will be regarded as the age of the file
    /// - Parameter attributes:       _optional_ The attributes from which to draw the age calculation. Based on the
    ///                               user's preference on which age to regard, this might never be used.
    func age(by whichAgeToRegard: WhichAgeToRegard, using attributes: @autoclosure FileAttributesGetter) -> Age? {
        func discoverDate() -> Date? {
            switch whichAgeToRegard {
            case .lastModificationDate:
                guard let attributes = try? attributes() else {
                    return nil
                }
                return modificationDate(using: attributes) ?? creationDate(using: attributes)
                
            case .originalCreationDate:
                guard let attributes = try? attributes() else {
                    return nil
                }
                return creationDate(using: attributes)
                
            case .dateWhenAddedToFolder:
                return self.dateAdded
            }
        }
        
        guard let date = discoverDate() else {
            return nil
        }
        
        return Age(value: Date.now.timeIntervalSince(date), unit: .second)
    }
    
    
    /// Attempts to find the modification date of this file
    ///
    /// - Parameter attributes: _optional_ The attributes from which to draw the modification date
    func modificationDate() -> Date? {
        guard let attributes = try? attributes() else { return nil }
        return modificationDate(using: attributes)
    }
    
    
    /// Attempts to find the modification date of this file
    ///
    /// - Parameter attributes: _optional_ The attributes from which to draw the modification date
    func modificationDate(using attributes: FileAttributes) -> Date? {
        return attributes[.modificationDate] as? Date
    }
    
    
    /// Attempts to find the creation date of this file
    ///
    /// - Parameter attributes: _optional_ The attributes from which to draw the creation date
    func creationDate(using attributes: FileAttributes) -> Date? {
        return attributes[.creationDate] as? Date
    }
    
    
    /// Attempts to find the creation date of this file
    ///
    /// - Parameter attributes: _optional_ The attributes from which to draw the creation date
    func creationDate() -> Date? {
        guard let attributes = try? attributes() else { return nil }
        return creationDate(using: attributes)
    }
    
    
    func attributes(using fileManager: FileManager = .default) throws -> FileAttributes {
        return try fileManager.attributesOfItem(atPath: actualPath)
    }
    
    
    typealias FileAttributesGetter = () throws -> FileAttributes
}



public extension URL {
    
    /// Attempts to delete this file
    ///
    /// - Parameter approach:       _optional_ The approach by which to delete the file. Defaults to `.trashing`.
    /// - Parameter fileManager:    _optional_ The file manager which will carry out the deletion. Defaults to `.standard`.
    /// - Parameter queueGenerator: _optional_ The queue on which to perform the deletion. Defaults to `.newDeleteQueue()`.
    /// - Parameter callback:       Called when the deletion has finished.
    func delete<FM: FileManagerProtocol>(
        by approach: DeleteApproach = .trashing,
        using fileManager: FM)
    async -> DeleteResult
    {
        guard startAccessingSecurityScopedResource() else {
            return .lackOfPermissions
        }
        defer { stopAccessingSecurityScopedResource() }
        
        do {
            switch approach {
            case .removing:
                log(debug: "Permanently deleting \(path)")
//                fatalError()
                try fileManager.removeItem(at: self)
                
            case .trashing:
                log(debug: "Sending \(path) to trash")
//                fatalError()
                try fileManager.trashItem(at: self, resultingItemURL: nil)
            }
            
            return .success
        }
        catch {
            log(error: error)
            return DeleteResult(error)
        }
    }
    
    
    
    typealias DeleteCallback = StrongCallback<DeleteResult>
    
    
    
    /// How a file should be deleted
    enum DeleteApproach {
        /// The standard Unix remove; actually delete the file from the file system
        case removing
        
        /// Send the file to the trash so it can be recovered
        case trashing
    }
    
    
    
    enum DeleteResult {
        case success
        case lackOfPermissions
        case noTrashOnDevice(NoTrashesError)
        case otherFailure(error: Error)
    }
}



internal extension URL.DeleteResult {
    init(_ someError: Error) {
        let nsError = someError as NSError
        
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case 3328: // Can we figure out which compile-time symbol corresponds to this magic number?
                self = .noTrashOnDevice(NoTrashesError(nsError))
                
            default:
                self = .otherFailure(error: someError)
            }
        }
        else {
            self = .otherFailure(error: someError)
        }
    }
}



public extension DispatchQueue {
    static func newDeleteQueue() -> DispatchQueue {
        return DispatchQueue(label: "Delete queue \(UUID())", qos: .utility)
    }
}



public extension Collection where Element == URL {
    
    /// Annotates every file and sorts that annotated collection so that the oldest ones are at the start of the array
    func annotatedAndSortedWithOldestAtStart() -> [AnnotatedFile] {
        
        func oldestFirst(a: AnnotatedFile, b: AnnotatedFile) -> Bool {
            if a.age > b.age {
                return .inAscendingOrder
            }
            else {
                return .inDecendingOrder
            }
        }
        
        
        return lazy
            .compactMap(\.annotated)
            .sorted(by: oldestFirst)
    }
    
    
    func annotated() -> Set<AnnotatedFile> {
        compactMapToSet(\.annotated)
    }
    
    
    /// Attempts to delete each and every file in this collection
    ///
    /// - Parameter approach:       _optional_ The approach by which to delete each file. Defaults to `.trashing`.
    /// - Parameter fileManager:    _optional_ The file manager which will carry out the deletion. Defaults to `.standard`.
    /// - Parameter queueGenerator: _optional_ The function which will generate a new queue on which to perform each deletion. Defaults to `{ .newDeleteQueue() }`.
    /// - Parameter callback:       Called when all the deletions have finished.
    func deleteAll<FMP: FileManagerProtocol>(
        by approach: DeleteApproach,
        using fileManager: FMP,
        on queueGenerator: @escaping JanitorKit.Generator<DispatchQueue> = { .newDeleteQueue() })
    async -> BatchDeleteResult {
        var numberOfCompletedDeleteAttempts: UInt = 0
        var failures = Set<DeletionFailure>()
        var successfulDeletions = Set<URL>()
        
        func onEachDeleted(url: URL, result: URL.DeleteResult) {
            numberOfCompletedDeleteAttempts += 1
            
            switch result {
            case .success:
                log(debug: "Successfully deleted the file at \(url.path)")
                successfulDeletions.insert(url)
                
            case .lackOfPermissions:
                log(error: "I don't have the right permissions to delete the file at \(url.path)")
                failures.insert(.init(url: url, error: LackOfPermissionsError()))
                
            case .noTrashOnDevice(let error):
                log(error: "I couldn't send \(url.lastPathComponent) to the trash because I couldn't find any trash cans on the drive that file is currently saved on. The operating system told me this:   \(error.localizedDescription)")
                failures.insert(.init(url: url, error: error))
                
            case .otherFailure(let error):
                log(error: "I don't know why, but I couldn't delete the file at \(url.path)")
                failures.insert(.init(url: url, error: error))
            }
        }
        
        
        for url in self {
            let deleteResult = await url.delete(by: approach, using: fileManager)
            onEachDeleted(url: url, result: deleteResult)
        }
        
        if failures.isEmpty {
            return .allSuccess
        }
        else if failures.count >= numberOfCompletedDeleteAttempts
                    || successfulDeletions.isEmpty {
            return .allFailed(errors: failures)
        }
        else {
            return .mixed(successfullyDeletedFiles: successfulDeletions,
                          remainingErrors: failures)
        }
    }
    
    
    func deleteAll(
        by approach: DeleteApproach,
        on queueGenerator: @escaping JanitorKit.Generator<DispatchQueue> = { .newDeleteQueue() })
    async -> BatchDeleteResult {
        await deleteAll(by: approach, using: .default, on: queueGenerator)
    }
    
    
    
    typealias DeleteApproach = Element.DeleteApproach
    
    typealias BatchDeleteCallback = StrongCallback<BatchDeleteResult>
}



public struct DeletionFailure: Error, Hashable {
    public let url: URL
    public let error: Error
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(bytes: withUnsafeBytes(of: error, echo))
    }
    
    
    public static func ==(lhs: DeletionFailure, rhs: DeletionFailure) -> Bool {
        return lhs.url == rhs.url
    }
}



public enum BatchDeleteResult {
    case allSuccess
    case mixed(successfullyDeletedFiles: Set<URL>, remainingErrors: Set<DeletionFailure>)
    case allFailed(errors: Set<DeletionFailure>)
}



public struct LackOfPermissionsError: Error {
}



public struct NoTrashesError: LocalizedError {
    let localizedDescription: String
    let localizedFailureReason: String
    
    init(_ originalError: NSError) {
        self.localizedDescription = originalError.localizedDescription
        self.localizedFailureReason = originalError.localizedFailureReason ?? ""
    }
}



public extension Dictionary where Key == FileAttributeKey {
    
    /// Gets and pareses the `.size` attribute out of this dictionary
    var size: DataSize? {
        guard let sizeNsNumber = self[.size] as? NSNumber else {
            return nil
        }
        
        return DataSize(value: sizeNsNumber.uintValue, unit: .byte)
    }
}



public typealias FileAttributes = [FileAttributeKey : Any]
