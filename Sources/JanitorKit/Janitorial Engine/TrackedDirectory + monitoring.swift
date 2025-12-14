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
        if let currentSize = trackedDirectory.currentTotalSize {
            self = .init(size: currentSize)
        }
        else {
            return nil
        }
    }
}
