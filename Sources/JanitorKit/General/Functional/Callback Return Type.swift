//
//  Callback Return Type.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-08-04.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation
@_exported import FunctionTools



/// Okay so I had this idea where any time you have a function that doesn't return normally but instead promises to call
/// a callback should have some way for the compiler to enforce that. And I figure the most natural way to do that in
/// the current Swift language version is to have that function return a standard "callback type". So if you miss
/// calling the callback on a branch it'll complain that there's a void return from a non-void function, and if you
/// call the callback without returning it'll complain that the value is unused. I don't know if this will end up being
/// a Good Idea™, but I figure this smaller project is a great place to try it out.
public enum ReturnsViaCallback {
    
    /// Signifies that you acknowledge that this is indeed a branch where the callback is not called, but promise that
    /// this is because it will be called from some external function which doesn't follow this pattern of having a
    /// special callback return type.
    case willReturnFromUntypedContext
    
    /// Signifies that you already called the callback and you can now safely return from the function
    case alreadyCalledCallbackInThisContext
    
    /// Signifies that you purposefulyl chose to never call the callback.
    /// - Attention: Make sure that this possibility is documented
    case purposefullyOptedToNeverCallCallback
    
    /// Signifies that you are iterating over some items, and will eventually call the callback, but not on this
    /// particular iteration as this won't be the final one.
    case willCallCallbackOnALaterIteration
    
    /// Signifies that this is the actual end of the last callback.
    /// All the work has been done and it's time to pop the stack.
    ///
    /// - Attention: Don't call this unless this is the actual end of the chain! If you are instead purposefully
    ///              deciding to not call some callback, then use another case of this enum.
    case thisIsTheTailEndOfTheCallbackChain
}



/// The return type used by callback blocks
public typealias CallbackReturnType = ReturnsViaCallback



public typealias StrongBlindCallback = () -> CallbackReturnType
public typealias StrongCallback<Result> = (Result) -> CallbackReturnType
public typealias StrongCallback2<ResultA, ResultB> = (ResultA, ResultB) -> CallbackReturnType
public typealias StrongChainedCallback<UltimateResult> = (Callback<UltimateResult>) -> ReturnsViaCallback



prefix operator <-



/// Signifies that you acknowledge that you are performing the final return with the callback, but the function returns void
///
/// For example:
/// ```swift
///  somethingThatTakesALegacyCallback {
///      performOperation()
///      return <- .thisIsTheTailEndOfTheCallbackChain
///  }
/// ```
@inlinable
public prefix func <- (_: CallbackReturnType) -> Void {}
