//
//  Semantic function aliases.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2020-03-07.
//  Copyright © 2020 Ky Leggiero. All rights reserved.
//

import Foundation



public extension Optional {
    @inline(__always)
    func ifNotNull<Return>(do operation: (Wrapped) throws -> Return) rethrows -> Return? {
        try map(operation)
    }
    
    
    @inline(__always)
    func ifNotNull<Return>(do operation: (Wrapped) throws -> Return?) rethrows -> Return? {
        try flatMap(operation)
    }
}
