//
//  JanitorialEngine + SwiftUI.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2021-07-25.
//

#if canImport(SwiftUI)
import SwiftUI

import Combine



extension JanitorialEngine: ObservableObject {}



public extension JanitorialEngine.ActivityFeed {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        public static let defaultValue = JanitorialEngine.ActivityFeed.dummyThatNeverPublishes()
    }
}



public extension EnvironmentValues {
    var janitorialEngineActivityFeed: JanitorialEngine.ActivityFeed {
        get { self[JanitorialEngine.ActivityFeed.EnvironmentKey.self] }
        set { self[JanitorialEngine.ActivityFeed.EnvironmentKey.self] = newValue }
    }
}

#endif
