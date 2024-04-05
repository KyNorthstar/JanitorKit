//
//  Measurement + auto-stringification.swift
//  
//
//  Created by Ky on 2024-04-04.
//

import Foundation

import BasicMathTools



public protocol SortedLengthCaseIterable: CaseIterable {
    static var allCases_sortedLongestFirst: AllCases { get }
}



// MARK: - Auto string

public extension Measurement where Unit: SortedLengthCaseIterable {
    
    /// Finds the best way to represent this measurement as a string, by using the smallest appropriate unit.
    ///
    /// For example, `4,194,304 seconds` will be represented as `"48.55 days"`,
    /// `3,371,549,327.36 seconds` will be represented as `"106.84 years"`,
    /// `3,360 seconds` will be represented as `"56 minutes"`,
    /// etc.
    ///
    /// ---
    ///
    /// There are some special cases where the returned output is guaranteed:
    ///
    /// |                     measurement value | `.bestDescription`
    /// | -------------------------------------:|:------------------
    /// |                                     0 | `"0 bases"`
    /// |           Not a number, or non-normal | `"NaN bases"`
    /// | `> Int.max`, `< Int.min`, or infinite | `"Infinity bases"`
    ///
    /// In the above table, substitute "`bases`" for the base unit of this measurement ("`seconds`", "`bits`", etc.)
    var bestDescription: String {
        let base = converted(to: .base)
        let baseValue = base.value
        
        guard !(baseValue ~== .zero) else {
            return "0 \(Unit.base.name.text(for: 0))"
        }
        
        guard baseValue.isNormal,
              !baseValue.isNaN
        else {
            return "NaN \(Unit.base.name.text(for: 0))"
        }
        
        guard baseValue.isFinite,
              (.init(Int.min) ... .init(Int.max)).contains(baseValue)
        else {
            return "\(baseValue.sign.description_excludingPlus)Infinity \(Unit.base.name.text(for: .max))"
        }
        
        let bestUnit = Unit
            .allCases_sortedLongestFirst
            .first_presortedLargestFirst(fitting: base)
            ?? .base
        
        let bestConversion = converted(to: bestUnit)
        
        let numberString = numberFormatter.format(.init(bestConversion.value))
        
        let unitString = bestUnit.name.text(for: Int(bestConversion.value))
        
        return "\(numberString) \(unitString)"
    }
}



private let numberFormatter = Decimal.FormatStyle().precision(.fractionLength(0...2))



extension FloatingPointSign: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .plus: "+"
        case .minus: "-"
        }
    }
    
    
    var description_excludingPlus: String {
        switch self {
        case .plus: ""
        case .minus: "-"
        }
    }
}
