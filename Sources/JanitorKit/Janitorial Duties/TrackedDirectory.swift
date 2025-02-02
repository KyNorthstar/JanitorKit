//
//  TrackedDirectory.swift
//  Janitor
//
//  Created by Ky Leggiero on 2019-07-19.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation

import SimpleLogging



/// Represents a directory tracked by Janitor
public struct TrackedDirectory {
    
    /// Uniquely identifies this tracked directory, even if its URL and everything about it changes
    public let uuid: UUID
    
    /// The user's dictated position that this holds in a list of tracked directories. This allows the user to manually sort tracked directories.
    ///
    /// Tracked directories with a `sort` set set always appear before tracked directories without one. Tracked directories without a `sort` set are still sorted deterministiclly, though not always intuitively.
    ///
    /// - If two tracked directories have an explicit `sort`, then they're sorted by that.
    /// - If one directory has a `sort` and the other doesn't, then the one with the `sort` goes first.
    /// - If neither have a `sort`, then ``backupSort`` is used instead.
    ///
    /// - SeeAlso: ``TrackedDirectory.<``
    public var sort: Int?
    
    /// Determines whether the application attempts to act upon this directory
    public var isEnabled: Bool
    
    /// The actual directory this is pointing to
    public var url: URL
    
    /// Files older than this should be acted upon
    public var oldestAllowedAge: Age
    
    // TODO: Add amnesty for very new files. For example, if someone downloads a huge DMG, they can still open it or move it before this deletes it
    // public var allowedAges: Age...Age
    
    /// If the directory is larger than this, its oldest files will be deleted even if they're newer than ``oldestAllowedAge``
    public var largestAllowedTotalSize: DataSize
    
    
    public init(uuid: UUID, sort: Int?, isEnabled: Bool = true, url: URL, oldestAllowedAge: Age, largestAllowedTotalSize: DataSize) {
        self.uuid = uuid
        self.sort = sort
        self.isEnabled = isEnabled
        self.url = url
        self.oldestAllowedAge = oldestAllowedAge
        self.largestAllowedTotalSize = largestAllowedTotalSize
    }
}



extension TrackedDirectory: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}



extension TrackedDirectory: Codable {}



extension TrackedDirectory: Identifiable {
    public var id: UUID { uuid }
}



public extension TrackedDirectory {
    /// The default instance of a tracked directory; a safe example to show and use as a base
    /// - Parameter customUuid: _optional_ - The UUID you want to use for the new default directory. If unspecified, a
    ///                         random new one will be created. If specified, that one will be used. Do **not** specify
    ///                         a UUID of an existing tracked directory will _not_ perform a lookup; it will only serve
    ///                         to create two tracked directories with the same UUID.
    static func `default`(customUuid: UUID = UUID()) -> TrackedDirectory {
        TrackedDirectory(uuid: customUuid,
                         sort: nil,
                         url: URL.User.downloads!,
                         oldestAllowedAge: 30.days,
                         largestAllowedTotalSize: 1.gigabytes)
    }
}



extension TrackedDirectory: CustomStringConvertible {
    public var description: String {
        """
        \(url.path)
            Oldest allowed age:         \(oldestAllowedAge)
            Largest allowed total size: \(largestAllowedTotalSize)
        """
    }
}



extension TrackedDirectory: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if let lhs_sort = lhs.sort {
            if let rhs_sort = rhs.sort {
                return lhs_sort < rhs_sort
            }
            else {
                // lhs has a sort, but rhs doesn't, so rhs goes first, so `lhs < rhs == false`
                return false
            }
        }
        else {
            // lhs doesn't have a sort
            
            if rhs.sort != nil {
                // lhs has no sort, but rhs does, so lhs goes first, so `lhs < rhs == true`
                return true
            }
            else {
                // Neither has a sort, so sort by the backup sort until the user starts sorting them
                return lhs.backupSort < rhs.backupSort
            }
        }
    }
    
    
    /// The value used for sorting if the user has not explicitly specified a sort order.
    ///
    /// This is guaranteed to be deterministic across runtimes, but might change across versions.
    private var backupSort: String {
        self.url.actualPath
    }
}
