//
//  PluralizableString.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-26.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



public struct PluralizableString {
    var singular: String
    var plurals: [PluralString]
}



public struct PluralString {
    let representedAmounts: Range<Int>
    let text: String
}



// MARK: - Conformance

extension PluralString: Hashable {}



extension PluralizableString: CustomStringConvertible {
    
    public var description: String {
        return ([singular] + plurals.map { $0.text }).joined(separator: "/")
    }
}



extension PluralizableString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(singular: value, plurals: [])
    }
}



extension PluralizableString: Hashable {}



extension Array: ExpressibleByDictionaryLiteral where Element == PluralString {
    
    public typealias Key = Int
    public typealias Value = String
    
    
    
    /// Allows you to express an array of plural strings as a dictionary
    ///
    /// ```
    /// let people: PluralizableString(
    ///     singular: "lonely",
    ///     plurals: [
    ///         2 : "company",
    ///         3 : "crowd",
    ///         5 : "party",
    ///     ]
    /// )
    /// ```
    ///
    /// This is analogous to:
    ///
    /// ```
    /// let people: PluralizableString(
    ///     singular: "lonely",
    ///     plurals: [
    ///         PluralString(representedAmount: 2 ..< 3,    text: "company"),
    ///         PluralString(representedAmount: 3 ..< 5,    text: "crowd"),
    ///         PluralString(representedAmount: 5 ..< .max, text: "party"),
    ///     ]
    /// )
    /// ```
    ///
    ///
    /// - Parameter pairs: Each key is the lower bound of the represented amount, and each value is the text
    public init(dictionaryLiteral pairs: (Key, Value)...) {
        guard let lastPair = pairs.last else {
            // No last pair = zero pairs = empty array
            self = []
            return
        }
        
        let allButLast = (pairs.dropLast() as ArraySlice<(Key, Value)>)
        
        self = allButLast.mapIndexed { index, pair in
            let currentRepresentedAmountLowerBound = pair.0
            let currentLocalizedText = pair.1
            let nextPairIndex = index.advanced(by: 1)
            let nextRepresentedAmountLowerBound = pairs[nextPairIndex].0
            
            return Element(representedAmounts: currentRepresentedAmountLowerBound ..< nextRepresentedAmountLowerBound,
                           text: currentLocalizedText)
        }
        
        self.append(Element(representedAmounts: lastPair.0 ..< .max,
                            text: lastPair.1))
    }
}



extension PluralizableString: Codable {}
extension PluralString: Codable {}



// MARK: - Conveniences

public extension PluralizableString {
    
    init(singular: String, plural: String) {
        self.init(singular: singular,
                  plurals: [PluralString(representedAmounts: 2 ..< .max, text: plural)]
        )
    }
    
    
    init(singular: String) {
        self.init(singular: singular, plurals: [])
    }
    
    
    func text(for amount: Int) -> String {
        if amount == 1 {
            return singular
        }
        else {
            return plurals
                .first { $0.representedAmounts.contains(amount) }?.text // If any matches it exactly, use that
                ?? plurals.first { $0.representedAmounts.contains(-amount) }?.text // Else, if any matches its negated form, use that (-3 degrees <=> 3 degrees)
                ?? plurals.first?.text // Else, if there are any plurals at all, use the first one (even if it didn't exactly match)
                ?? singular // Else, if there are no plurals at all, use the singular
        }
    }
    
    
    func text<Amount: BinaryFloatingPoint>(whenAmountIs amount: Amount) -> String {
        return text(for: Int(amount.rounded()))
    }
}



// MARK: - Oerators

func | (lhs: String, rhs: String) -> PluralizableString {
    return PluralizableString(singular: lhs, plural: rhs)
}


func + (lhs: String, rhs: String) -> PluralizableString {
    return PluralizableString(singular: lhs, plural: lhs + rhs)
}
