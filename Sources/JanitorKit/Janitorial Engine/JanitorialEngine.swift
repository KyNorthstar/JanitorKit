//
//  JanitorialEngine.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2021-07-25.
//

import Combine
import Foundation

import CollectionTools
import SimpleLogging



typealias RunLoopPublisher<Value> = Publishers.ReceiveOn<Published<Value>.Publisher, RunLoop>

private var janitorialEngineCounter = 0 {
    willSet {
        if newValue > 1 {
            log(fatal: "More than 1 JanitorialEngine!")
            assertionFailure()
        }
    }
}



/// The core engine of Janitor. This coordinates multiple Single-Directory Janitors, taking care of their lifecycles and concurrency.
public final actor JanitorialEngine {
    
    // MARK: Private
    
    /// The janitors performing the work within this engine
    private var janitors: [SingleDirectoryJanitor] = []
    
    /// The backend for the activity feed
//    private let mostRecentActivityPublisher: RunLoopPublisher<ActivityOrPlaceholder> = {
//        var published = Published(initialValue: ActivityOrPlaceholder.placeholderWhileEngineStarts)
//        return published.projectedValue.receive(on: RunLoop.main)
//    }()
    @MainActor
    @Published
    private var mostRecentActivity = ActivityOrPlaceholder.placeholderWhileEngineStarts
    
    
    // MARK: Public
    
    /// Subscribe to this to receive updates about the janitorial engine and read its state
    @MainActor
    public private(set) var activityFeed: ActivityFeed
    
    
    /// Whether the janitorial engine is still preparing.
    ///
    /// "Preparing" is the initial state of the engine, before it's prepared to do anything. When the engine is not preparing, it's running.
    ///
    /// Future versions might see the "preparing" state happen outside initial startup, for example if it needs to shut down to respond to some major change.
    private var isPreparing = true {
        didSet {
            guard oldValue != isPreparing else { return }
            Task {
                log(verbose: "Telling everyone that isPreparing changed from \(oldValue) to \(isPreparing)")
                await announceCurrentRunningState()
            }
        }
    }
    
    
    /// Whether to perform a "dry run", where actions are pretended but no changes are made.
    private(set) internal var dryRun: Bool {
        didSet {
            guard oldValue != dryRun else { return }
            Task {
                log(verbose: "Telling everyone that dryRun changed from \(oldValue) to \(dryRun)")
                await announceCurrentRunningState()
            }
        }
    }
    
    
    // MARK: Init
    
    /// Creates a new Janitorial Engine, but doesn't start it yet. After this, you must specifically call `start()` to start the engine.
    ///
    /// - Parameters:
    ///   - dryRun:   _optional_ - Iff `true`, no files will be removed, but this will act as if they were anyway. Defaults to `false`
    ///   - janitors: The janitors to start with. To coordinate more janitors later, call `.coordinate(janitor:)`
    @MainActor
    public init(dryRun: Bool = false, preparing janitors: [SingleDirectoryJanitor]) {
        janitorialEngineCounter += 1
        
        self.dryRun = dryRun
        self.janitors = janitors
        self.activityFeed = .dummyThatNeverPublishes() // Gotta do this or else the Swift compiler gets worried that I'm accessing `mostRecentActivity` before `activityFeed` is initialized
        
        self.activityFeed = $mostRecentActivity.createActivityFeed()
        
        self.runOnThisActor {
            self.isPreparing = false // I don't know how to communicate to Swift 6 that this is OK, but I do know that it is
        }
    }
}



internal extension Actor {
    nonisolated func runOnThisActor(_ action: @escaping (_ self: Self) -> Void) {
        Task {
            await _runOnThisActor(action)
        }
    }
    
    
    func _runOnThisActor(_ action: (_ self: Self) -> Void) {
        action(self)
    }
}



// MARK: - Public Interaction & Control

public extension JanitorialEngine {
    
    /// Creates a new Janitorial Engine, but doesn't start it yet. After this, you must specifically call `start()` to start the engine.
    ///
    /// - Parameters:
    ///   - dryRun:   _optional_ - Iff `true`, no files will be removed, but this will act as if they were anyway. Defaults to `false`
    ///   - trackedDirectories: The directories which should be kept clean. Janitors will be created for each one. To coordinate more later, call `.coordinate(janitorFor:)`
    @MainActor
    init(dryRun: Bool = false, preparingJanitorsFor trackedDirectories: [TrackedDirectory]) {
        self.init(dryRun: dryRun, preparing: trackedDirectories.map { SingleDirectoryJanitor(trackedDirectory: $0) })
    }
    
    
    /// A way to interpret the janitors in this engine as the directories they track
    var trackedDirectories: [TrackedDirectory] {
        get { janitors.map { $0.trackedDirectory } }
    }
    
    
    /// A way to change the janitors in this engine using the directories they track
    func setTrackedDirectories(_ newValue: [TrackedDirectory]) async {
        let changes = newValue.difference(from: trackedDirectories)
        
        for change in changes {
            switch change {
            case .insert(offset: _, element: let newDirectory, associatedWith: _):
                await coordinate(janitor: .init(trackedDirectory: newDirectory))
                
            case .remove(offset: _, element: let oldDirectory, associatedWith: _):
                retire(janitorTracking: oldDirectory)
            }
            
            let newDirectories = trackedDirectories
            
            await announce(.trackedDirectoriesDidChange(newDirectories: newDirectories))
        }
    }
    
    
    /// Changes whether this engine is running in "dry run" mode, meaning it will pretend to delete items but won't actually perform the deletion
    ///
    /// - Attention: Changing this is an expensive operation! Do not toggle this lightly; all janitors will be immediately stopped, reconfigured, and started again
    func setDryRun(_ newValue: Bool) async {
        let oldValue = self.dryRun
        guard oldValue != newValue else { return }
        
        self.dryRun = newValue
        
        await restartAll()
    }
    
    
    /// Starts the janitorial engine, coordinating all its janitors to keep their directories clean
    func start() async {
        await startAll()
    }
    
    
    /// Coordinates a new janitor with exiting ones, to ensure it can clean its directory efficiently, the new one dedicated to the given tracked directory.
    ///
    /// This inherently starts the new janitor immediately.
    ///
    /// - Parameter trackedDirectory: The directory for the new janitor to be coordinated
    func coordinate(janitorFor trackedDirectory: TrackedDirectory) async {
        await coordinate(janitor: .init(trackedDirectory: trackedDirectory))
    }
    
    
    /// Coordinates the given janitor with exiting ones, to ensure it can clean its directory efficiently.
    ///
    /// This inherently starts the janitor immediately.
    ///
    /// - Parameter janitor: The janitor to coordinate
    func coordinate(janitor: SingleDirectoryJanitor) async {
        self.janitors += janitor
        
        await start(janitor)
    }
    
    
    /// Stops coordinating the given janitor.
    ///
    /// This inherently stops the janitor immediately.
    ///
    /// - Parameter janitor: The janitor to stop coordinating
    func retire(janitor: SingleDirectoryJanitor) {
        self.janitors.remove(firstElementWithId: janitor.id)
    }
    
    
    /// Stops coordinating the janitor which is tracking the given directory.
    /// 
    /// This inherently stops the janitor immediately.
    ///
    /// - Parameter directoryToRemove: The directory being tracked by a janitor which is to stop coordinating
    func retire(janitorTracking directoryToRemove: TrackedDirectory) {
        if let foundIndex = trackedDirectories.firstIndex(of: directoryToRemove) {
            janitors.remove(at: foundIndex)
        }
        else {
            log(warning: "I was asked to retire the janitor tracking this directory, but I don't think any of my jnitors were keeping track of it: \(directoryToRemove)")
        }
    }
    
    
//    private func _setDryRun(_ closure: @escaping @Sendable @autoclosure () -> Bool) {
//        _dryRun = closure()
//    }
    
    
//    nonisolated var dryRun: Bool {
//        get { enqueue { await self._dryRun } }
//        set { enqueue { await self._setDryRun(newValue)} }
//    }
}



// MARK: - Activity feed & state

public extension JanitorialEngine {
    /// The current running state of the janitorial engine.
    ///
    /// This describes how/whether the engine is running. Read this when you need to know its current broad state, such as "is it even on?"
    fileprivate(set) var currentRunningState: RunningState {
        get {
            if isPreparing {
                .preparing
            }
            else if dryRun {
                .dryRun
            }
            else {
                .ready
            }
        }
        
        
        set {
            let isPreparing: Bool
            let dryRun: Bool
            
            switch newValue {
            case .preparing:
                isPreparing = true
                dryRun = self.dryRun
                
            case .dryRun:
                isPreparing = false
                dryRun = true
                
            case .ready:
                isPreparing = false
                dryRun = false
            }
            
            (self.isPreparing, self.dryRun) = (isPreparing, dryRun)
        }
    }
}



private extension JanitorialEngine {
    enum ActivityOrPlaceholder {
        case placeholderWhileEngineStarts
        case activity(Activity)
    }
}



public extension JanitorialEngine {
    
    /// An item of activity performed by this janitorial engine
    enum Activity {
        
        /// An error occurred
        case error(JanitorialEngine.Error)
        
        /// Signaled when the whole janitorial engine starts/stops
        case janitorialEngineRunningStateDidChange(runningState: RunningState)
        
        /// The janitorial engine has started a janitor
        /// - Parameter id: The ID of the janitor which was stopped
        case janitorDidStart(id: SingleDirectoryJanitor.ID)
        
        /// The janitorial engine has stopped a janitor
        /// - Parameter id: The ID of the janitor which was stopped
        case janitorDidStop(id: SingleDirectoryJanitor.ID)
        
        /// An item was removed from the drive
        case didRemoveFile
        
        /// The tracked directories are differnet
        /// - Parameter newDirectories: The new list of all tracked directories after the change
        case trackedDirectoriesDidChange(newDirectories: [TrackedDirectory])
        
        
        static let ready = janitorialEngineRunningStateDidChange(runningState: .ready)
    }
    
    
    
    /// Describes one of the exclusive states of how/whether a janitorial engine is running
    enum RunningState {
        
        /// The janitorial engine is starting up but not yet ready
        case preparing
        
        /// The janitorial engine is ready and running what janitors it has enabled
        case ready
        
        /// The janitorial engine is ready and will emulate running but won't cause any permanent changes
        case dryRun
    }
}



public extension JanitorialEngine {
    enum Error: Swift.Error {
        
        /// An error occurred which was wholly unexpected by the developers of `JanitorKit`, so can't be expressed semantically at compile-time
        case unexpectedError(Swift.Error)
        
        /// A janitor coordinated by this engine tried to remove an item, but could not
        case couldNotRemoveItem(failedItem: AnnotatedFile, failureReason: Swift.Error)
    }
}



public extension JanitorialEngine {
    
    typealias ActivityFeed = AnyPublisher<Activity, Never>
}



private extension JanitorialEngine {
    
    /// Tells all subscribers that the given activity has occurred
    ///
    /// - Parameter activity: The activity to publish to subscribers
    func announce(_ activity: Activity) async {
        await MainActor.run {
            self.mostRecentActivity = .activity(activity)
        }
    }
    
    
    func announceCurrentRunningState() async {
        await announce(.janitorialEngineRunningStateDidChange(runningState: currentRunningState))
    }
}



private extension Published<JanitorialEngine.ActivityOrPlaceholder>.Publisher {
    func createActivityFeed() -> JanitorialEngine.ActivityFeed {
        compactMap { activityOrError in
            switch activityOrError {
            case .activity(let activity):
                return activity
                
            case .placeholderWhileEngineStarts:
                return nil
            }
        }
        .removeDuplicates(by: { lhs, rhs in
            switch (lhs, rhs) {
            // Consider these duplicates:
            case (.janitorialEngineRunningStateDidChange(runningState: let lhsRunningState),
                  .janitorialEngineRunningStateDidChange(runningState: let rhsRunningState))
                where lhsRunningState == rhsRunningState:
                return true
                
            case (.janitorDidStart(id: let lhsId),
                  .janitorDidStart(id: let rhsId)),
                 (.janitorDidStop(id: let lhsId),
                  .janitorDidStop(id: let rhsId)):
                return lhsId == rhsId
                
            case (.didRemoveFile,
                  .didRemoveFile):
                return true
                
            case (.trackedDirectoriesDidChange(newDirectories: let lhsNewDirectories),
                  .trackedDirectoriesDidChange(newDirectories: let rhsNewDirectories))
                where lhsNewDirectories == rhsNewDirectories:
                return true
                
                
            // Don't consider these duplicates:
                
            case (.error(_), .error(_)):
                return false
                
            case (.error(_), _),
                (.janitorialEngineRunningStateDidChange(runningState: _), _),
                (.janitorDidStart(id: _), _),
                (.janitorDidStop(id: _), _),
                (.didRemoveFile, _),
                (.trackedDirectoriesDidChange(newDirectories: _), _):
                return false
            }
        })
        .eraseToAnyPublisher()
    }
}



public extension JanitorialEngine.ActivityFeed {
    var runningStateChanges: AnyPublisher<JanitorialEngine.RunningState, Never> {
        compactMap { activity in
            switch activity {
            case .janitorialEngineRunningStateDidChange(runningState: let runningState):
                return runningState
                
            default:
                return nil
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}



// MARK: - Private conveniences

private extension JanitorialEngine {
    
    static let taskPriority = TaskPriority.background
    
    
    func startAll() async {
        await enqueue { [self] in
            for janitor in await janitors {
                await janitor.start(dryRun: dryRun)
            }
        }
    }
    
    
    func stopAll() async {
        await enqueue { [self] in
            for janitor in await janitors {
                await janitor.stop()
            }
        }
    }
    
    
    func restartAll() async {
        await enqueue { [self] in
            for janitor in await janitors {
                await janitor.stop()
                await janitor.start(dryRun: dryRun)
            }
        }
    }
    
    
    func start(_ janitor: SingleDirectoryJanitor) async {
        await enqueue { [self] in
            await janitor.start(dryRun: dryRun)
        }
    }
    
    
    func stop(_ janitor: SingleDirectoryJanitor) async {
        await enqueue {
            await janitor.stop()
        }
    }
    
    
    func restart(_ janitor: SingleDirectoryJanitor) async {
        await enqueue { [self] in
            await janitor.stop()
            await janitor.start(dryRun: dryRun)
        }
    }
}



private func enqueue(_ task: @escaping @Sendable () async -> Void) async {
    await Task(priority: JanitorialEngine.taskPriority) {
        await task()
    }
    .value
}


private func enqueue<Value>(_ task: @escaping @Sendable () async -> Value) async -> Value {
    await Task(priority: JanitorialEngine.taskPriority) {
        await task()
    }
    .value
}
