//
//  MeasurementUnit.swift
//  Janitor
//
//  Created by Ky Leggiero on 2019-07-25.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



// MARK: - MeasurementUnit

public protocol MeasurementUnit: Identifiable, Codable, Hashable, CaseIterable where AllCases: RandomAccessCollection {

    static var base: Self { get }
    
    var symbol: String { get }
    var name: PluralizableString { get }
    
    
    /// Converts the given value (assuming it's representing measurement in this unit) to the analogous value in the ``base`` unit
    ///
    /// - Parameter valueInThisUnit: The current value, representing a measurement in this unit
    ///
    /// - Returns: The analogous value in the base unit
    func convertToBase(value valueInThisUnit: Value) -> Value
    
    
    /// Converts the given value (assuming it's representing measurement in the ``base`` unit) to the analogous value in this unit
    ///
    /// - Parameter valueInBaseUnit: The other value, representing a measurement in the base unit
    ///
    /// - Returns: The analogous value in this unit
    func convertFromBase(value valueInBaseUnit: Value) -> Value
    
    
    /// Converts the given value from this unit to the given one
    ///
    /// - Parameters:
    ///   - thisValue:   The value to be converted
    ///   - thatUnit: The new unit to convert to
    ///
    /// - Returns: The new value as expressed in the given unit
    func convert(value thisValue: Value, to thatUnit: Self) -> Value
    
    
    /// Converts the given value from the given unit to this one
    ///
    /// - Parameters:
    ///   - thatValue:   The value to be converted
    ///   - thatUnit: The old unit to convert from
    ///
    /// - Returns: The new value as expressed in this unit
    func convert(value thatValue: Value, from thatUnit: Self) -> Value
    
    
    
    typealias Value = CGFloat.NativeType
}



// MARK: - LinearMeasurementUnit

public protocol LinearMeasurementUnit: MeasurementUnit {
    
    /// Divide a value in the base unit by `coefficient` to get the value in this unit.
    /// Multiply `coefficient` by a value in this unit to get the same value in the base unit.
    var coefficient: Value { get }
}



public extension LinearMeasurementUnit {
    
    func convertToBase(value valueInThisUnit: Value) -> Value {
        valueInThisUnit * coefficient
    }
    
    
    func convert(value thisValue: Value, to thatUnit: Self) -> Value {
        thatUnit.convertFromBase(value: convertToBase(value: thisValue))
    }
    
    
    func convertFromBase(value valueInBaseUnit: Value) -> Value {
        valueInBaseUnit / coefficient
    }
    
    
    func convert(value thatValue: Value, from thatUnit: Self) -> Value {
        convertFromBase(value: thatUnit.convertToBase(value: thatValue))
    }
}



// MARK: - SwiftUI.Identifiable

public extension MeasurementUnit {
    var id: String {
        return symbol
    }
}



public extension LinearMeasurementUnit {
    var id: Value {
        return coefficient
    }
}
