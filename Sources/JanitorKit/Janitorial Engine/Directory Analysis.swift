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
    
    /// Lists all items within this directory, along with stats we're concerned about
    /// - Complexity: O(2n)
    /// - Returns: A set of all files in this directory, annotated with stats we're concerned about
    func annotatedContents() async -> Set<AnnotatedFile> {
        url
        .allChildren()
        .annotated()
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
    /// - Returns: The set of files this function reccomends be deleted
    func filesThatShouldBeDeleted() async -> Set<URL> {
        __inputPresorted__filesThatShouldBeDeleted(
            in:
                url
                .allChildren()
                .annotatedAndSortedWithOldestAtStart()
        )
            .mapToSet { $0.url }
    }
    
    
    /// Determines which files should be deleted automatically within the current rules
    ///
    /// 🌟 This is the star function of this package. Its functionality is crucial to the whole point of the package
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
    private func __inputPresorted__filesThatShouldBeDeleted(
        in annotatedFiles_sortedOldestToNewest: [AnnotatedFile])
    -> Set<AnnotatedFile> {
        // TODO: Test
        logEntry(); defer { logExit() }
        
        let totalSizeBeforeCleaning = annotatedFiles_sortedOldestToNewest
            .lazy
            .map { $0.size }
            .reduce(into: .zero, +=)
        
        var totalSizeOfFilesToBeCleaned = DataSize.zero
        
        var expectedSizeAfterCleaning: DataSize {
            totalSizeBeforeCleaning - totalSizeOfFilesToBeCleaned
        }
        
        let _oldNew = annotatedFiles_sortedOldestToNewest.split(maxSplits: 1, omittingEmptySubsequences: false) { annotatedFile in
            let isTooOld = annotatedFile.age > oldestAllowedAge
            if isTooOld {
                totalSizeOfFilesToBeCleaned += annotatedFile.size
            }
            let shouldSplitHere = !isTooOld
            return shouldSplitHere
        }
        
        let oldFiles = Set(_oldNew[orNil: 0] ?? [])
        let new_sortedOldestToNewest = _oldNew[orNil: 1] ?? []
        
        // expectedTotalSizeOfFilesToBeCleaned = oldFiles.map(\.size).reduce(into: .zero, +=)
        
        if expectedSizeAfterCleaning < largestAllowedTotalSize {
            // If we've only looked at old files, and already know that deleting those will get us within quota without
            // having to look at big ones yet, then just select those old files for deletion.
            log(info: "Found \(totalSizeOfFilesToBeCleaned.bestDescription) of old files to remove (\(oldFiles.count) files)")
            return oldFiles
        }
        else {
            // If deleting all the old files still doesn't get us within the quota, then start adding the remaining
            // files (sorted oldest first) until we know we'll get back within the quota
            log(info: "Found \(oldFiles.count) old files to be removed (\(totalSizeOfFilesToBeCleaned.bestDescription) total), but must still remove more to bring the \(totalSizeBeforeCleaning.bestDescription) directory within the \(largestAllowedTotalSize.bestDescription) quota...")
            
            let oldFilesSize = totalSizeOfFilesToBeCleaned
            
            let bigFiles = Set(new_sortedOldestToNewest
                .prefix(while: { annotatedFile in
                    guard expectedSizeAfterCleaning > largestAllowedTotalSize else { return false }
                    
                    let thisFileSize = annotatedFile.size
                    let totalSizeOfFilesToBeCleaned_includingThisOne = totalSizeOfFilesToBeCleaned + thisFileSize
                    totalSizeOfFilesToBeCleaned = totalSizeOfFilesToBeCleaned_includingThisOne
                    
                    return true
//                    let expectedSizeAfterCleaning_includingThisOne = totalSizeBeforeCleaning - totalSizeOfFilesToBeCleaned_includingThisOne
//                    let wouldStillBeOutsideQuota = expectedSizeAfterCleaning_includingThisOne > largestAllowedTotalSize
//                    return wouldStillBeOutsideQuota
                })
            )
            
            let bigFilesSize = totalSizeOfFilesToBeCleaned - oldFilesSize
            log(info: "Found \(oldFilesSize.bestDescription) of old files (\(oldFiles.count)) and \(bigFilesSize.bestDescription) of big files (\(bigFiles.count)) to remove (\(totalSizeOfFilesToBeCleaned.bestDescription) total across all \(oldFiles.count + bigFiles.count) files), bringing the total directory size down to \(expectedSizeAfterCleaning.bestDescription), which is within the quota of \(largestAllowedTotalSize.bestDescription) for \(url.path)")
            
            assert(oldFiles.isDisjoint(with: bigFiles), "oldFiles and bigFiles must refer to completely different files")
            
            return oldFiles + bigFiles
        }
    }
}
