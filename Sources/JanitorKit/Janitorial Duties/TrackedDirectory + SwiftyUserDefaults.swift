//
//  TrackedDirectory + SwiftyUserDefaults.swift
//  
//
//  Created by Ky Leggiero on 2021-07-17.
//

import Foundation

import SwiftyUserDefaults



extension TrackedDirectory: DefaultsSerializable {
    public typealias Bridge = DefaultsCodableBridge<Self>
    public typealias ArrayBridge = DefaultsArrayBridge<[Self]>
}
