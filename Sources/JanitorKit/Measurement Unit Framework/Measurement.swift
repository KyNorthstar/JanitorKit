//
//  Measurement.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-25.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



public struct Measurement<Unit: MeasurementUnit> {
    public var value: Value
    public var unit: Unit
    
    
    public init(value: Value, unit: Unit) {
        self.value = value
        self.unit = unit
    }
}



// MARK: - Conveniences

public extension Measurement {
    typealias Value = MeasurementUnit.Value
    
    
    
    init(converting measurement: Measurement<Unit>, to newUnit: Unit) {
        self = measurement.converted(to: newUnit)
    }
    
    
    static var zero: Measurement<Unit> { 0 }
}



extension Measurement: AdditiveArithmetic {
    public static func + (lhs: Measurement<Unit>, rhs: Measurement<Unit>) -> Measurement<Unit> {
        return Measurement(value: lhs.convertingToBase.value + rhs.convertingToBase.value,
                           unit: .base)
    }
    
    
    public static func += (lhs: inout Measurement<Unit>, rhs: Measurement<Unit>) {
        lhs = lhs + rhs
    }
    
    
    public static func - (lhs: Measurement<Unit>, rhs: Measurement<Unit>) -> Measurement<Unit> {
        return Measurement(value: lhs.convertingToBase.value - rhs.convertingToBase.value,
                           unit: .base)
    }
    
    
    public static func -= (lhs: inout Measurement<Unit>, rhs: Measurement<Unit>) {
        lhs = lhs - rhs
    }
}



// MARK: - General Conformance

extension Measurement: Hashable {}
extension Measurement: Codable {}



extension Measurement: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.convertingToBase.value == rhs.convertingToBase.value
    }
}



extension Measurement: CustomStringConvertible {
    public var description: String {
        return "\(valueString) \(unit.name.text(whenAmountIs: value))"
    }
    
    
    private var valueString: String {
        numberFormatter.string(from: NSNumber(value: value)) ?? value.description
    }
}



extension Measurement: CustomDebugStringConvertible {
    public var debugDescription: String { "\(value) \(unit.symbol)" }
}



private let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.alwaysShowsDecimalSeparator = false
    return numberFormatter
}()



// MARK: - SimpleInitializableUnitDependent

extension Measurement: SimpleInitializableUnitDependent {
}
