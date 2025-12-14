//
//  UpdatePipelineActor.swift
//  JanitorKit
//
//  Created by Ky on 2025-08-13.
//

import Foundation



@globalActor
public final actor UpdatePipelineActor: GlobalActor {
    public static let shared = UpdatePipelineActor()
    public typealias ActorType = UpdatePipelineActor
}



//public extension GlobalActor where ActorType == Self {
//    /// Runs the given code on this actor
//    ///
//    /// - Parameter body: <#body description#>
//    /// - Returns: <#description#>
//    func sync<Return>(_ body: () async -> Return) async -> Return {
//        await body()
//    }
//    
//    
//    static func sync<Return>(_ body: () async -> Return) async -> Return {
//        await shared.sync(body)
//    }
//}
