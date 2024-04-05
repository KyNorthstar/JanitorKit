//
//  Collection + measurement functions.swift
//
//
//  Created by Ky on 2024-04-04.
//

import Foundation




public extension Collection where Element: MeasurementUnit {
    
    /// Finds the first measurement unit by which the given `measurement` can be represented as greater than `0` and less than `stepSize`.
    ///
    /// - Note: Obviously, this works best if this collection is sorted before calling this. This function does not perform any sorting.
    ///
    /// - Complexity: O(n)
    ///
    /// - Parameters:
    ///   - measurement: The mesurement whose best-fitting unit to find
    ///   - stepSize:    The number of values between units.
    ///                  We could have written this on `BiDirectionalCollection` and looked ahead and behind to make this more automatic, but that would take more effort from Us _and_ the program
    ///
    /// - Returns: The unit which represents the given measurement best, or `nil` if none could be found
    func first_presortedShortestFirst(fitting measurement: Measurement<Element>, withinStep stepSize: CGFloat) -> Element? {
        first { unit in
            let unitValue = measurement.converted(to: unit).value
            return unitValue < stepSize
                && unitValue > 0
        }
    }
    
    /// Finds the first measurement unit by which the given `measurement` can be represented as greater than `0`.
    ///
    /// - Note: Obviously, this works best if this collection is sorted so that the largest is first before calling this. This function does not perform any sorting.
    ///
    /// - Complexity: O(n)
    ///
    /// - Parameters:
    ///   - measurement: The mesurement whose best-fitting unit to find
    ///
    /// - Returns: The unit which represents the given measurement best, or `nil` if none could be found
    func first_presortedLargestFirst(fitting measurement: Measurement<Element>) -> Element? {
        first { unit in
            Int(floor(measurement.converted(to: unit).value)) > 0
        }
    }
}
