//
//  Age.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-19.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



/// The age of something, such as seconds, hours, nanoseconds, etc.
public typealias Age = Measurement<DurationMeasurementUnit>



// MARK: - CaseIterable

extension DurationMeasurementUnit: CaseIterable {
    
    public typealias AllCases = [DurationMeasurementUnit]
    
    
    
    public static let allCases: AllCases = [
        .year,
        .week,
        .day,
        .hour,
        .minute,
        .second,
        .millisecond,
        .microsecond,
        .nanosecond,
        .picosecond,
    ]
    
    public static let commonFileAgeCases: AllCases = [
        .year,
        .week,
        .day,
        .hour,
        .minute,
    ]
}



// MARK: - Stdlib Extensions

public extension BinaryFloatingPoint {
    var years:        Age { Age(value: Age.Value(self), unit: .year) }
    var weeks:        Age { Age(value: Age.Value(self), unit: .week) }
    var days:         Age { Age(value: Age.Value(self), unit: .day) }
    var hours:        Age { Age(value: Age.Value(self), unit: .hour) }
    var minutes:      Age { Age(value: Age.Value(self), unit: .minute) }
    var seconds:      Age { Age(value: Age.Value(self), unit: .second) }
    var milliseconds: Age { Age(value: Age.Value(self), unit: .millisecond) }
    var microseconds: Age { Age(value: Age.Value(self), unit: .microsecond) }
    var nanoseconds:  Age { Age(value: Age.Value(self), unit: .nanosecond) }
    var picoseconds:  Age { Age(value: Age.Value(self), unit: .picosecond) }
}



public extension TimeInterval {
    init(_ age: Age) {
        self.init(age.converted(to: .second).value)
    }
}
