//
//  Comparable extensions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2021-07-25.
//

import Foundation

import RangeTools



public extension RangeWithLowerAndUpperBound {
    func clamp(_ value: Bound) -> Bound {
        max(
            lowerBound,
            min(
                value,
                upperBound
            )
        )
    }
}



public extension RangeWithLowerBound {
    func clamp(_ value: Bound) -> Bound {
        max(lowerBound, value)
    }
}



public extension RangeWithUpperBound {
    func clamp(_ value: Bound) -> Bound {
        min(value, upperBound)
    }
}
