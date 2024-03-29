//
//  UserPreferences.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-19.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation
import FunctionTools



public enum UserPreferences {
    // Empty on-purpose; all members are static
}



public extension UserPreferences {
    @UserDefault("trackedDirectories")
    static var trackedDirectories = [
        TrackedDirectory(uuid: UUID(), isEnabled: false, url: URL.User.downloads!, oldestAllowedAge: 30.days, largestAllowedTotalSize: 1.gibibytes),
        TrackedDirectory(uuid: UUID(), isEnabled: false, url: URL.User.desktop!, oldestAllowedAge: 90.days, largestAllowedTotalSize: 5.gibibytes),
        ] {
        didSet {
            trackedDirectoryChangeListeners.forEachIgnoringReturn(call(passing: trackedDirectories))
        }
    }
    
    private static var trackedDirectoryChangeListeners = [OnTrackedDirectoryDidChange]()
    
    
    static func onTrackedDirectoriesDidChange(callback: @escaping OnTrackedDirectoryDidChange) {
        trackedDirectoryChangeListeners.append(callback)
    }
    
    
    
    typealias OnTrackedDirectoryDidChange = StrongCallback<[TrackedDirectory]>
}



public extension UserPreferences {
    
    @UserDefault("checkingDelay")
    static var checkingDelay = 5.minutes {
       didSet {
           checkingDelayChangeListeners.forEachIgnoringReturn(call(passing: checkingDelay))
       }
   }
   
   private static var checkingDelayChangeListeners = [OnCheckingDelayDidChange]()
   
   
   static func onCheckingDelayDidChange(callback: @escaping OnCheckingDelayDidChange) {
       checkingDelayChangeListeners.append(callback)
   }
   
   
   
   typealias OnCheckingDelayDidChange = StrongCallback<Age>
}



public extension UserPreferences {
    
    @UserDefault("whichAgeToRegard")
    static var whichAgeToRegard = WhichAgeToRegard.lastModificationDate
}



/// The kind of age to regard when determining how old a file is
public enum WhichAgeToRegard: UInt8, Codable {
    /// Files which were more recently modified are considered younger.
    ///
    /// If never modified, this is the same as `originalCreationDate`.
    case lastModificationDate = 0
    
    /// Files which were more recently created are considered younger
    ///
    /// This might not be what you want if you didn't make the file (think about copying from backups or downloading an
    /// old archive which preserved its creation dates).
    ///
    /// Additionally, this might delete files which are frequently used, as the modification date won't be considered.
    case originalCreationDate = 1
    
    /// Files which were more recently added to this folder are considered younger.
    ///
    /// This might not be what you want, because this might delete files which are frequently used, as the modification date won't be considered.
    case dateWhenAddedToFolder = 2
}
