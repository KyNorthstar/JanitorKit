//
//  Unit Conversion.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-19.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



/// Anything which has a value which is dependent on a unit for context
public protocol UnitDependent: HasBaseUnit, Comparable where Unit: MeasurementUnit {
    
    /// The raw value, in the context of the unit
    var value: Value { get }
    
    /// The unit of the raw value
    var unit: Unit { get }
    
    
    
    typealias Value = Double
}



public extension UnitDependent {
    static var baseUnit: Unit { Unit.base }
}



// MARK: - SimpleInitializableUnitDependent

/// Any `UnitDependent` which can be simply initialized using solely a value and a unit
public protocol SimpleInitializableUnitDependent: UnitDependent, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    init(value: Value, unit: Unit)
}



public extension SimpleInitializableUnitDependent {
    
    init(converting other: Self, to newUnit: Self.Unit) {
        self = other.converted(to: newUnit)
    }
    
    
    /// Converts this value in its unit to a new value in the given other unit
    func converted(to otherUnit: Self.Unit) -> Self {
        let selfBaseValue = self.unit.convertToBase(value: value)
        let otherValue = otherUnit.convertFromBase(value: selfBaseValue)
        return Self.init(value: otherValue, unit: otherUnit)
    }
}



public extension SimpleInitializableUnitDependent {
    
    init(inBaseUnit baseUnitValue: Value) {
        self.init(value: baseUnitValue, unit: Self.baseUnit)
    }
    
    
    init<AnyInt>(value: AnyInt, unit: Unit) where AnyInt: BinaryInteger {
        self.init(value: Value(value), unit: unit)
    }
    
    
    init(floatLiteral: Value) {
        self.init(inBaseUnit: floatLiteral)
    }
    
    
    init(integerLiteral value: Int) {
        self.init(inBaseUnit: Value(value))
    }
}



public extension SimpleInitializableUnitDependent { // : HasBaseUnit
    
    func converted(to other: Self) -> Value {
        return other.unit.convertFromBase(value: unit.convertToBase(value: value))
    }
    
    
    var convertingToBase: Measurement<Unit> {
        return Measurement(value: unit.convertToBase(value: value), unit: Unit.base)
    }
}



// MARK: - HasBaseUnit

public protocol HasBaseUnit {

    /// The important unit of the value
    associatedtype Unit
    
    /// The unit upon which all other units of this kind are based
    static var baseUnit: Unit { get }
}



// MARK: - Comparable

extension UnitDependent where Self: SimpleInitializableUnitDependent {
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.convertingToBase.value < rhs.convertingToBase.value
    }
}
