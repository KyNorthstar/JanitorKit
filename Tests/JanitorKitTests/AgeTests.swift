//
//  AgeTests.swift
//  JanitorKitTests
//
//  Created by Ky Leggiero on 2019-07-19.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import XCTest
@testable import JanitorKit



final class AgeTests: XCTestCase {
    
    func testCustomUnits_days() {
        let numberOfSecondsPerDay = 86_400
        
        let oneDayInSeconds = Age(value: numberOfSecondsPerDay, unit: .second)
        let oneDayInDays = oneDayInSeconds.converted(to: .day)
        XCTAssertEqual(oneDayInDays.value, 1)
        
        XCTAssertEqual(oneDayInDays.converted(to: .second).value, Age.Value(numberOfSecondsPerDay))
    }
    
    
    func testCustomUnits_weeks() {
        let numberOfSecondsPerWeek = 604_800
        
        let oneWeekInSeconds = Age(value: numberOfSecondsPerWeek, unit: .second)
        let oneDayInDays = oneWeekInSeconds.converted(to: .week)
        XCTAssertEqual(oneDayInDays.value, 1)
        
        XCTAssertEqual(oneDayInDays.converted(to: .second).value, Age.Value(numberOfSecondsPerWeek))
    }
    
    
    func testCustomUnits_years() {
        let numberOfSecondsPerYear = 31_556_925.216
        
        let oneYearInSeconds = Age(value: numberOfSecondsPerYear, unit: .second)
        let oneDayInDays = oneYearInSeconds.converted(to: .year)
        XCTAssertEqual(oneDayInDays.value, 1, accuracy: 0.000_000_1)
        
        XCTAssertEqual(oneDayInDays.converted(to: .second).value, Age.Value(numberOfSecondsPerYear))
    }
    
    
    static var allTests = [
        ("testCustomUnits_days", testCustomUnits_days),
        ("testCustomUnits_weeks", testCustomUnits_weeks),
        ("testCustomUnits_years", testCustomUnits_years),
    ]
}
