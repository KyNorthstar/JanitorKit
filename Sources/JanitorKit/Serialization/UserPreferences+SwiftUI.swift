//
//  UserPreferences+SwiftUI.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-26.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import SwiftUI
import FunctionTools



public extension UserPreferences {
    enum Bindings {
        // Empty on-purpose; all members are static
    }
}



public extension UserPreferences.Bindings {
    @BoundPointer
    private static var trackedDirectoriesBoundPointer: [TrackedDirectory] = {
        defer {
            UserPreferences.onTrackedDirectoriesDidChange { (newTrackedDirectories) in
                UserPreferences.Bindings.trackedDirectoriesBoundPointer = newTrackedDirectories
                return .thisIsTheTailEndOfTheCallbackChain
            }
        }
        return UserPreferences.trackedDirectories
    }()
    
    static var trackedDirectories: Binding<[TrackedDirectory]> {
        _trackedDirectoriesBoundPointer.binding
    }
    
    
    @BoundPointer
    private static var checkingDelayBoundPointer: Age = {
        defer {
            UserPreferences.onCheckingDelayDidChange { (newCheckingDelay) in
                UserPreferences.Bindings.checkingDelayBoundPointer = newCheckingDelay
                return .thisIsTheTailEndOfTheCallbackChain
            }
        }
        return UserPreferences.checkingDelay
    }()
    
    static var checkingDelay: Binding<Age> {
        _checkingDelayBoundPointer.binding
    }
}
