//
//  FileManager extensions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2021-07-30.
//

import Foundation



public protocol FileManagerProtocol {
    
    func unmountVolume(at url: URL, options mask: FileManager.UnmountOptions, completionHandler: @escaping @Sendable (Error?) -> Void)
    func unmountVolume(at url: URL, options mask: FileManager.UnmountOptions) async throws
    
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
    
    func createSymbolicLink(at url: URL, withDestinationURL destURL: URL) throws
    func createSymbolicLink(atPath path: String, withDestinationPath destPath: String) throws
    
    func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAtPath path: String) throws
    
    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func copyItem(atPath srcPath: String, toPath dstPath: String) throws
    
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func moveItem(atPath srcPath: String, toPath dstPath: String) throws
    
    func linkItem(at srcURL: URL, to dstURL: URL) throws
    func linkItem(atPath srcPath: String, toPath dstPath: String) throws
    
    func removeItem(at URL: URL) throws
    func removeItem(atPath path: String) throws
    
    func trashItem(at url: URL, resultingItemURL outResultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws
    
    func changeCurrentDirectoryPath(_ path: String) -> Bool
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
    
    func replaceItem(at originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String?, options: FileManager.ItemReplacementOptions, resultingItemURL resultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws
    
    func setUbiquitous(_ flag: Bool, itemAt url: URL, destinationURL: URL) throws
    func startDownloadingUbiquitousItem(at url: URL) throws
    func evictUbiquitousItem(at url: URL) throws
}



public extension FileManagerProtocol {
    func unmountVolume(at url: URL, completionHandler: @escaping @Sendable (Error?) -> Void) {
        unmountVolume(at: url, options: [], completionHandler: completionHandler)
    }
    
    
    func unmountVolume(at url: URL) async throws {
        try await unmountVolume(at: url, options: [])
    }
    
    
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        try createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: nil)
    }
    
    
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool) throws {
        try createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: nil)
    }
    
    
    func createFile(atPath path: String, contents data: Data?) -> Bool {
        createFile(atPath: path, contents: data, attributes: nil)
    }
    
    
    func replaceItem(at originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String?, resultingItemURL resultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws {
        try replaceItem(at: originalItemURL, withItemAt: newItemURL, backupItemName: backupItemName, options: [], resultingItemURL: resultingURL)
    }
}



extension FileManager: FileManagerProtocol {}



public extension FileManagerProtocol where Self == DryRunFileManager {
    
    /// A file manager which performs no actions. No state will change at all, neither volatile nor persistent.
    ///
    /// All "read" operations will perform as always. All "write" operations will silently do nothing.
    /// For example, `isDeletableWritableFile(atPath:)` might return `true`, but `removeItem(atPath:)` will still not delete the file.
    ///
    /// Operations which provide a return value describing how they changed state, like `createFile(atPath:contents:)`, will accurately reuturn a value describing that the state was not changed.
    ///
    /// This performs as expected for Apple SDKs as of:
    /// - macOS 12
    /// - iOS 15
    /// - tvOS 15
    /// - watchOS 8
    ///
    /// Future SDKs might add new mutation methods. If so, this will _not_ perofrm as expected, since it works by overriding mutation methods with no-op versions, and the new ones would not be overridden.
    ///
    /// - Attention: If, for any reason, this changes any state, report that as a bug here: https://github.com/KyLeggiero/JanitorKit/issues/new
    static var dryRun: Self { Self() }
}



public extension FileManagerProtocol where Self == Foundation.FileManager {
    static var `default`: Self { Foundation.FileManager.default }
}



/// The implementation behind `FileManager.dryRun`.
/// This is a version of `FileManager` which never does anything, and always reports silence (or that it did nothing, if some report is required)
public final class DryRunFileManager: Sendable, FileManagerProtocol {
    
    @nonobjc
    public func unmountVolume(at url: URL, options mask: FileManager.UnmountOptions = [], completionHandler: @escaping @Sendable (Error?) -> Void) { completionHandler(nil) }
    public func unmountVolume(at url: URL, options mask: FileManager.UnmountOptions = []) async throws {}
    
    public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {}
    public func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {}
    
    public func createSymbolicLink(at url: URL, withDestinationURL destURL: URL) throws {}
    public func createSymbolicLink(atPath path: String, withDestinationPath destPath: String) throws {}
    
    public func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAtPath path: String) throws {}
    
    public func copyItem(at srcURL: URL, to dstURL: URL) throws {}
    public func copyItem(atPath srcPath: String, toPath dstPath: String) throws {}
    
    public func moveItem(at srcURL: URL, to dstURL: URL) throws {}
    public func moveItem(atPath srcPath: String, toPath dstPath: String) throws {}
    
    public func linkItem(at srcURL: URL, to dstURL: URL) throws {}
    public func linkItem(atPath srcPath: String, toPath dstPath: String) throws {}
    
    public func removeItem(at URL: URL) throws {}
    public func removeItem(atPath path: String) throws {}
    
    public func trashItem(at url: URL, resultingItemURL outResultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws {}
    
    public func changeCurrentDirectoryPath(_ path: String) -> Bool { false }
    
    public func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]? = nil) -> Bool { false }
    
    public func replaceItem(at originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String?, options: FileManager.ItemReplacementOptions = [], resultingItemURL resultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws {}
    
    public func setUbiquitous(_ flag: Bool, itemAt url: URL, destinationURL: URL) throws {}
    public func startDownloadingUbiquitousItem(at url: URL) throws {}
    public func evictUbiquitousItem(at url: URL) throws {}
}
