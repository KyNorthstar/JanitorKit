//
//  AnyPublisher extensions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2021-08-22.
//

import Combine



internal extension AnyPublisher {
    
    /// I created this for moments when the Swift compiler gets worried that I'm accessing an instance's field in its initializer before all fields are initialized.
    ///
    /// This will never publish anything; it simply exists as the correct type, as a placeholder when needed.
    static func dummyThatNeverPublishes() -> Self {
        [Output]().publisher
            .setFailureType(to: Failure.self)
            .filter { _ in false } // Just in case
            .eraseToAnyPublisher()
    }
}
