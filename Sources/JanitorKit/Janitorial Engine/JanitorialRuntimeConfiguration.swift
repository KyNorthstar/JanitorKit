//
//  JanitorialRuntimeConfiguration.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2021-07-25.
//

import Foundation

import SwiftyUserDefaults



public struct JanitorialRuntimeConfiguration {
    
    @SwiftyUserDefault(keyPath: \.dryRun)
    public var dryRun: Bool
}



private extension DefaultsKeys {
    var dryRun: DefaultsKey<Bool> { .init("dryRun", defaultValue: true) }
}
