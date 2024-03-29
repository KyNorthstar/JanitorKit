//
//  Directory Analysis.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-08-03.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation

import SafeCollectionAccess
import SimpleLogging



internal extension TrackedDirectory {
    
    /// Determines which files should be deleted automatically within the current rules
    ///
    /// This will always look at age first. It will always recommend to delete files which are older than the oldest allowed age.
    /// Then, once all the old files are considered, if the folder would still be over the total allowed folder size, this will work through which files are large, working backwards by age.
    ///
    /// That is to say, assuming you follow the output of this function:
    /// - Files older than ``oldestAllowedAge`` will always be deleted
    /// - If that still doesn't get us within the size quota, more files are deleted (starting with the oldest) until we are within the quota
    ///
    /// - Returns: The set of files this function reccomends be deleted
    func filesThatShouldBeDeleted() async -> Set<URL> {
        __inputPresorted__filesThathouldFileBeDeleted(
            in:
                url
                .allChildren()
                .annotatedAndSortedWithOldestAtStart()
        )
            .mapToSet { $0.url }
    }
    
    
    /// Determines which files should be deleted automatically within the current rules
    /// 
    /// This will always look at age first. It will always recommend to delete files which are older than the oldest allowed age.
    /// Then, once all the old files are considered, if the folder would still be over the total allowed folder size, this will work through which files are large, working backwards by age.
    /// 
    /// That is to say, assuming you follow the output of this function:
    /// - Files older than ``oldestAllowedAge`` will always be deleted
    /// - If that still doesn't get us within the size quota, more files are deleted (starting with the oldest) until we are within the quota
    /// 
    /// - Parameter annotatedFiles_sortedOldestToNewest: All files in the directory, annotated, pre-sorted so the oldest is at the start
    /// - Returns: The set of files this function reccomends be deleted
    private func __inputPresorted__filesThathouldFileBeDeleted(
        in annotatedFiles_sortedOldestToNewest: [AnnotatedFile])
    -> Set<AnnotatedFile> {
        // TODO: Test
        logEntry(); defer { logExit() }
        
        let totalSize = annotatedFiles_sortedOldestToNewest
            .lazy
            .map { $0.size }
            .reduce(into: .zero, +=)
        
        var expectedTotalSizeOfFilesToBeCleaned = DataSize.zero
        
        var expectedSizeAfterCleaning: DataSize {
            totalSize - expectedTotalSizeOfFilesToBeCleaned
        }
        
        let _oldNew = annotatedFiles_sortedOldestToNewest.split(maxSplits: 1, omittingEmptySubsequences: false) { annotatedFile in
            let isOld = annotatedFile.age > oldestAllowedAge
            if isOld {
                expectedTotalSizeOfFilesToBeCleaned += annotatedFile.size
            }
            return isOld
        }
        
        let oldFiles = Set(_oldNew[orNil: 0] ?? [])
        let new_sortedOldestToNewest = _oldNew[orNil: 1] ?? []
        
        if expectedSizeAfterCleaning < largestAllowedTotalSize {
            // If we've only looked at old files, and already know that deleting those will get us within quota without
            // having to look at big ones yet, then just select those old files for deletion.
            log(info: "Found \(expectedTotalSizeOfFilesToBeCleaned) of old files to remove")
            return oldFiles
        }
        else {
            // If deleting all the old files still doesn't get us within the quota, then start adding the remaining
            // files (sorted oldest first) until we know we'll get back within the quota
            log(info: "Found \(expectedTotalSizeOfFilesToBeCleaned.bestDescription) of old files to be removed, but must still remove more to bring the \(totalSize.bestDescription) directory within the \(largestAllowedTotalSize.bestDescription) quota...")
            
            let oldFilesSize = expectedTotalSizeOfFilesToBeCleaned
            
            let bigFiles = Set(new_sortedOldestToNewest
                .suffix(startingFrom: { annotatedFile in
                    expectedTotalSizeOfFilesToBeCleaned += annotatedFile.size
                    return expectedSizeAfterCleaning < largestAllowedTotalSize
                })
            )
            
            let bigFilesSize = expectedTotalSizeOfFilesToBeCleaned - oldFilesSize
            log(info: "Found \(oldFilesSize) of old files and \(bigFilesSize) of big files to remove (\(expectedTotalSizeOfFilesToBeCleaned) total)")
            
            return oldFiles + bigFiles
        }
    }
}
