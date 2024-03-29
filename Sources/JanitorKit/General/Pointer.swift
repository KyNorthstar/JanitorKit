//
//  Pointer.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-28.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



@propertyWrapper
public class Pointer<Pointee> {
    
    public var wrappedValue: Pointee {
        get { pointee }
        set { pointee = newValue }
    }
    
    public var pointee: Pointee {
        didSet { onPointeeDidChange(pointee) }
    }
    
    public var onPointeeDidChange: OnPointeeDidChange
    
    
    public init(pointee: Pointee, onPointeeDidChange: @escaping OnPointeeDidChange = { _ in }) {
        self.pointee = pointee
        self.onPointeeDidChange = onPointeeDidChange
    }
    
    
    public convenience init(wrappedValue: Pointee, onPointeeDidChange: @escaping OnPointeeDidChange = { _ in }) {
        self.init(pointee: wrappedValue, onPointeeDidChange: onPointeeDidChange)
    }
    
    
    
    public typealias OnPointeeDidChange = (_ newValue: Pointee) -> Void
}



prefix operator *



public prefix func * <Pointee> (rhs: Pointee) -> Pointer<Pointee> {
    return Pointer(pointee: rhs)
}
