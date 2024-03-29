//
//  Prefab Functions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-08-06.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation
import FunctionTools



/// Creates a callback caller, which when called will pass the given value to the callback. This is useful for calling
/// many callbacks all at once which all get the same value.
///
/// ```
/// var arrayOfCallbacks = [(String) -> Void]()
///
/// // ... later ...
///
/// arrayOfCallbacks.forEach(call(passing: "Foobar"))
/// ```
///
/// - Parameter input: The value to pass to the callback
///
/// - Returns: A function which will pass `input` to any function passed to it
public func call<Input>(passing input: Input) -> (_ callback: StrongCallback<Input>) -> CallbackReturnType {
    return { callback in
        return callback(input)
    }
}
