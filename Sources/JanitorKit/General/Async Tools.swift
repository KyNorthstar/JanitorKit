//
//  Async Tools.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2021-07-31.
//

import Foundation
import FunctionTools



//@MainActor
//public func sync<Value>(at priority: TaskPriority? = nil, _ asyncValue: @escaping () async -> Value) -> Value {
//    
////    let semaphore = DispatchSemaphore.init(value: 0)
//    
//    let awaiter = Awaiter<Value>()
//    
////    MainActor.shared.enqueue(UnownedJob)
//    
//    
////    let result = Task.detached(priority: priority) {
////        defer { semaphore.signal() }
//        awaiter.result = await asyncValue()
////    }
////    .result
////
////    semaphore.wait()
////
////    FunctionTools.blackhole(result)
//    
//    return awaiter.result!
//}
//
//
//
//private class Awaiter<Value> {
//    var result = Optional<Value>.none
//}
