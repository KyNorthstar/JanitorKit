//
//  SingleDirectoryJanitor.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-08-03.
//  Copyright © 2019 Ky Leggiero BH-1-PS
//

import Combine
import Foundation

import SimpleLogging



/// This will dedicate itself to ensuring that one directory never gets out of control, by
/// trashing files which are older than a certain age, or which push that directory over a certain size.
///
/// This was designed to have multiple engines running at once; one for each tracked directory.
public actor SingleDirectoryJanitor {
    
    /// The directory that this janitor is tracking
    public nonisolated let trackedDirectory: TrackedDirectory // ✅ nonisolated OK because this is a `let`
    
    public let priority: TaskPriority
    
    public let checkingInterval: TimeInterval
    
    public let deletionApproach: URL.DeleteApproach
    
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var isCurrentlyChecking = false
    
    @Published
    private var directoryState: TrackedDirectory.Status?
    
    
    public init(
        trackedDirectory: TrackedDirectory,
        priority: TaskPriority = .utility,
        checkingInterval: TimeInterval,
        deletionApproach: URL.DeleteApproach = .trashing)
    {
        self.trackedDirectory = trackedDirectory
        self.priority         = priority
        self.checkingInterval = checkingInterval
        self.deletionApproach = deletionApproach
    }
    
    deinit {
        log(verbose: "Deinitializing \(self)")
    }
}



public extension SingleDirectoryJanitor {
    
    private static var filesystemChecks: Set<AnyCancellable> = []
    
    init(
        trackedDirectory: TrackedDirectory,
        deletionApproach: URL.DeleteApproach = .trashing)
    {
        self.init(
            trackedDirectory: trackedDirectory,
            checkingInterval: (1.minutes ... 15.minutes)
                .clamp(trackedDirectory.oldestAllowedAge)
                .converted(to: .second).value,
            deletionApproach: deletionApproach)
    }
    
    /// Starts the janitorial engine, immediately performing the check and scheduling future checks intelligently (heuristcally)
    ///
    /// - Parameter dryRun: If `true`, no files will be deleted, but lines will be logged describing the action that would have been taken instead
    func start(dryRun: Bool) async {
        stop()
        
        guard trackedDirectory.isEnabled else { return }
        
        let url = trackedDirectory.url
        
        log(info: "Going to automatically perform checks whenever file changes are detected in \(url.path)")
        url.fileChanges()
            .filter {
                // Don't worry about observing deletions; the whole point of this app is to auto-delete, so if something deletes a file (incl. this app), then that's just less work for this app
                switch $0 {
                case .added(newFilePaths: _),
                        .modified(modifiedPaths: _):
                    return true
                    
                case .removed(defunctPaths: _):
                    return false
                }
            }
            .sink { completion in
                log(info: "File changes have stopped in \(url) • \(completion)")
            } receiveValue: { change in
                log(verbose: "Change received: \(change)")
                
                Task { [weak self] in
                    guard let self else { return }
                    let checkResult = await self.performCheck(dryRun: dryRun)
                    if let directoryState = TrackedDirectory.Status(for: self.trackedDirectory) {
                        self.runOnThisActor { `self` in
                             self.directoryState = directoryState
                        }
                    }
                }
            }
            .store(in: &Self.filesystemChecks)

        
        log(info: "Going to automatically perform checks every \(Age(value: checkingInterval, unit: .second).bestDescription)")
        Timer.publish(every: checkingInterval, on: .main, in: .default)
            .sink { completion in
                log(info: "Timer has stopped in \(url) • \(completion)")
            } receiveValue: { [self] _ in Task(priority: priority) {
                log(verbose: "It's been \(checkingInterval) seconds since the last check; performing one now")
                await performCheck(dryRun: dryRun)
            } }
            .store(in: &cancellables)
        
        log(info: "Performing first check...")
        await performCheck(dryRun: dryRun)
    }
    
    
    /// Immediately stops the janitorial engine. No questions asked, no strings attached
    func stop() {
        cancellables.removeAll()
    }
    
    
    
    /// The kind of block called when the engine successfully starts
    typealias DidStartCallback = StrongBlindCallback
    
    /// The kind of block called when the engine successfully stops
    typealias DidStopCallback = StrongBlindCallback
    
    /// The kind of block called when the engine successfully restarts
    typealias DidRestartCallback = DidStartCallback
}



private extension SingleDirectoryJanitor {
    
    
    @discardableResult
    func performCheck(dryRun: Bool) async -> CheckResult {
        logEntry(); defer { logExit() }
        
        guard !isCurrentlyChecking else {
            log(debug: "Another check is already running; skipping this one")
            return .checkSkipped
        }
        
        isCurrentlyChecking = true
        defer { isCurrentlyChecking = false }
        
        let filesThatShouldBeDeleted = await trackedDirectory.filesThatShouldBeDeleted()
        
        guard !filesThatShouldBeDeleted.isEmpty else {
            log(debug: "Checked all files in this directory and there was no need to delete any: \(trackedDirectory)")
            return .allFilesWereGood
        }
        
        let batchDeleteResult: BatchDeleteResult
        
        if dryRun {
            log(info: "DRY RUN: Scheduling \(filesThatShouldBeDeleted.count) files for deletion from \(trackedDirectory.url.path)")
            batchDeleteResult = await filesThatShouldBeDeleted.deleteAll(by: .trashing, using: .dryRun)
        }
        else {
            log(info: "Scheduling \(filesThatShouldBeDeleted.count) files for deletion from \(trackedDirectory.url.path)")
            batchDeleteResult = await filesThatShouldBeDeleted.deleteAll(by: .trashing, using: .default_sendable)
        }
        
        switch batchDeleteResult {
        case .allSuccess:
            log(info: "Successfully cleaned out \(filesThatShouldBeDeleted.count) files from \(trackedDirectory.url.path)")
            return .successfullyCleaned(cleanedUpFiles: filesThatShouldBeDeleted)
            
        case .mixed(let successes, let remainingErrors):
            log(error: "Failed to cleaned out \(remainingErrors.count) files, but succeeded in cleaning out \(successes.count) files from \(trackedDirectory.url.path)")
            return .failedToCleanSomeBadFiles(cleanedUpFiles: successes, uncleanFiles: remainingErrors)
            
        case .allFailed(let uncleanFiles):
            log(error: "Failed to cleaned out any of the \(uncleanFiles.count) files selected for removal from \(trackedDirectory.url.path)")
            return .failedToCleanAllBadFiles(uncleanFiles: uncleanFiles)
        }
    }
    
    
    
    typealias DidPreformCheckCallback = StrongCallback<CheckResult>
    
    
    
    /// The result of checking a directory for files to be removed
    enum CheckResult {
        
        /// The check was purposefully not performed for some reason
        case checkSkipped
        
        /// The check was performed and didn't find any files to remove
        case allFilesWereGood
        
        /// The check was performed, and found files to remove, and successfully removed those files
        case successfullyCleaned(cleanedUpFiles: Set<URL>)
        
        /// The check was performed, and found files to remove, and removed some of those files, but not all of them
        case failedToCleanSomeBadFiles(cleanedUpFiles: Set<URL>, uncleanFiles: Set<UncleanFile>)
        
        /// The check was performed, and found files to remove, but couldn't remove any of those files
        case failedToCleanAllBadFiles(uncleanFiles: Set<UncleanFile>)
    }
    
    
    
    typealias UncleanFile = DeletionFailure
}



extension SingleDirectoryJanitor: Identifiable {
    
    nonisolated public var id: TrackedDirectory.ID { trackedDirectory.id }
    
    
    public static func == (lhs: SingleDirectoryJanitor, rhs: SingleDirectoryJanitor) -> Bool {
        lhs.trackedDirectory == rhs.trackedDirectory
    }
    
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(trackedDirectory)
    }
}
