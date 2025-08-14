//
//  TrackedDirectory + monitoring.swift
//  JanitorKit
//
//  Created by Ky on 2025-07-28.
//

import Combine
import Foundation



// MARK: Status

public extension TrackedDirectory {
    /// Some summary info about a tracked directory
    struct Status {
        public let size: Size
    }
}



public extension TrackedDirectory.Status {
    init?(for trackedDirectory: TrackedDirectory) {
        if let currentSize = trackedDirectory.currentSize {
            self = .init(size: currentSize)
        }
        else {
            return nil
        }
    }
}



// MARK: Size

public extension TrackedDirectory {
    /// Data size information about a tracked directory
    struct Size {
        public let absoluteValue: DataSize
        public let quota: DataSize
    }
}



public extension TrackedDirectory.Size {
    var quotaPercentage: CGFloat {
        absoluteValue.convertingToBase.value / quota.convertingToBase.value
    }
}



public extension TrackedDirectory {
    
    var currentSize: Size? {
        guard let dataSize = url.annotated?.size else { return nil }
        return Size(absoluteValue: dataSize, quota: largestAllowedTotalSize)
    }
}
