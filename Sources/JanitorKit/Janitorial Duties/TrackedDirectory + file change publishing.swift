//
//  TrackedDirectory + file change publishing.swift
//  JanitorKit
//
//  Created by Ky on 2025-10-23.
//

import Combine
import Foundation

import SimpleLogging



public extension TrackedDirectory {
    func anyFileChangePublisher() -> FileChangePublisher {
        url.fileChanges()
    }
    
    func fileStatsChangePublisher() -> AnyPublisher<FileSizeChange, Never> {
        anyFileChangePublisher()
            .compactMap { (change: FileChange) -> [String]? in
                switch change {
                case .added(newFilePaths: _),
                        .removed(defunctPaths: _):
                    return nil
                    
                case .modified(modifiedPaths: let paths):
                    return paths
                }
            }
            .replaceError(with: [String]?.none)
            .compactMap(\.self)
            .map { (modifiedPaths: [String]) -> [FileSizeChange] in
                modifiedPaths
                    .map { modifiedPath in
                        let dataSize: DataSize? = {
                            guard let bytes = try? FileManager.default.attributesOfItem(atPath: modifiedPath)[.size] as? NSNumber else {
                                log(error: "Could not get attributes of a recently-modified file, so I couldn't get its size: \(modifiedPath)")
                                return nil
                            }
                            
                            return DataSize(inBaseUnit: .init(bytes.intValue))
                        }()
                        
                        return (path: modifiedPath, size: dataSize)
                    }
            }
            .flatMap { fileSizeChanges in
                fileSizeChanges
                    .publisher
            }
            //.removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    
    /// Publishes a new value every time the total size of all files in this directory changes
    ///
    /// If the files change but the size remains the same, this _doesn't_ publish anything
    @available(macOS 15.0, *)
    func totalSizeChangePublisher() -> some AsyncSequence<Stats, Never> {
        var cancellables: Set<AnyCancellable> = []
        return AsyncStream(
            tranceiving: anyFileChangePublisher()
                .map { Optional.some($0) }
                .replaceError(with: nil)
                .compactMap(\.self)
                .eraseToAnyPublisher(),
            storeIn: &cancellables)
            .map { _ in
                await self.currentStats
            }
    }
    
    
    
    typealias FileSizeChange = (path: String, size: DataSize?)
}
