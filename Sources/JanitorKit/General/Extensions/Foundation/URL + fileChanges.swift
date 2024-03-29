//
//  FilesystemWatcher.swift
//  Janitor
//
//  Created by Ky on 2024-03-16.
//

import Combine
import Foundation

import FunctionTools
import SimpleLogging



public extension URL {
    func fileChanges() -> FileChangePublisher {
        class Shim {
            @Published
            var fileChange: Result<FileChange, FilesystemObservationError>? = nil
            
            var watcher: DirectoryChangeWatcher? 
            
            
            init(actualPath: String) {
                watcher = nil
                
                watcher = DirectoryChangeWatcher(observedDirectoryPath: actualPath) { [weak self] changeResult in
                    guard let self else { return }
                    
                    switch changeResult {
                    case .success(let changes):
                        for change in changes {
                            fileChange = .success(change)
                        }
                        
                    case .failure(let error):
                        fileChange = .failure(.init(error))
                    }
                }
            }
        }
        
        
        
        var shim: Shim? = Shim(actualPath: actualPath)
        
        return shim! //! I'm sure that Shim will exist on the line immediately after it's created
            .$fileChange
            .tryCompactMap { result in
                try result?.get()
            }
            .mapError { error in
                if let error = error as? FilesystemObservationError {
                    return error
                }
                else {
                    return .unknownError(error)
                }
            }
            .handleEvents(receiveCompletion: { completion in
                defer { shim = nil } // Hopefully deallocate the shim and watcher. This shouldn't affect the above "shim!" line
                
                switch completion {
                case .finished:
                    break
                    
                case .failure(let filesystemObservationError):
                    log(error: filesystemObservationError)
                }
            })
            .eraseToAnyPublisher()
    }
}



public typealias FileChangePublisher = AnyPublisher<FileChange, FilesystemObservationError>



public enum FileChange {
    case added(newFilePaths: [String])
    case modified(modifiedPaths: [String])
    case removed(defunctPaths: [String])
}



public enum FilesystemObservationError: Error {
    case unknownError(Error)
    
    
    fileprivate init(_ other: DirectoryChangeWatcher.Error) {
        switch other {
        case .couldNotCreateFilesytemEventStream:
            self = .unknownError(other)
        }
    }
}



private final class DirectoryChangeWatcher {
    
    private static let listeningQueue = DispatchQueue(label: "\(DirectoryChangeWatcher.self)")
    
    
    private let observedDirectoryPath: String
    private let changeCallback: ChangeCallback
    private var stream: FSEventStreamRef?
    
    
    init(observedDirectoryPath: String, changeCallback: @escaping ChangeCallback) {
        self.observedDirectoryPath = observedDirectoryPath
        self.changeCallback = changeCallback
        
        start()
    }
    
    
    deinit {
        stop()
    }
    
    
    private func start() {
        if stream != nil {
            stop()
        }

        var context = FSEventStreamContext(version: 0, info: UnsafeMutableRawPointer(mutating: Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
        guard let stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            innerEventCallback,
            &context,
            [observedDirectoryPath] as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0,
            UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        )
        else {
            changeCallback(.failure(Error.couldNotCreateFilesytemEventStream))
            return
        }
        
        self.stream = stream
        
        FSEventStreamSetDispatchQueue(stream, Self.listeningQueue)
        
        FSEventStreamStart(stream)
    }

    
    private func stop() {
        guard let stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        self.stream = nil
    }
    
    
    private let innerEventCallback: FSEventStreamCallback = { (
        stream: ConstFSEventStreamRef,
        contextInfo: UnsafeMutableRawPointer?,
        numEvents: Int,
        eventPaths: UnsafeMutableRawPointer,
        eventFlags: UnsafePointer<FSEventStreamEventFlags>,
        eventIds: UnsafePointer<FSEventStreamEventId>)
        in
        
        let `self` = unsafeBitCast(contextInfo, to: DirectoryChangeWatcher.self)
        let eventPaths = unsafeBitCast(eventPaths, to: NSArray.self) as! [String]

        var created = [String]()
        var modified = [String]()
        var removed = [String]()
        
        for eventIndex in 0 ..< numEvents {
            let eventFlag = Int(eventFlags[eventIndex])
            let path = eventPaths[eventIndex]
            
            if (kFSEventStreamEventFlagItemCreated | eventFlag) != 0 {
                created.append(path)
            }
            if (kFSEventStreamEventFlagItemModified | eventFlag) != 0 {
                modified.append(path)
            }
            if (kFSEventStreamEventFlagItemRemoved | eventFlag) != 0 {
                removed.append(path)
            }
            
//            kFSEventStreamEventFlagItemRenamed
        }
        
        self.changeCallback(.success([
            .removed(defunctPaths: removed),
            .modified(modifiedPaths: modified),
            .added(newFilePaths: created),
        ]))
        
//        fsWatcher.onChangeCallback?(fileEvents)
    }
    
    
    
    public typealias ChangeCallback = (Result<[FileChange], Error>) -> Void
    
    
    
    enum Error: Swift.Error {
        case couldNotCreateFilesytemEventStream
    }
}
