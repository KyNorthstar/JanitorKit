//
//  DurationMeasurementUnit.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-26.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



public struct DurationMeasurementUnit: LinearMeasurementUnit {
    
    public static var base = DurationMeasurementUnit.second
    
    public var coefficient: Value
    public var symbol: String
    public var name: PluralizableString
}



public extension DurationMeasurementUnit {
    static let year             = DurationMeasurementUnit(coefficient: meanTropicalYear.coefficient,           symbol: "y",  name: "year"+"s")
    static let meanTropicalYear = DurationMeasurementUnit(coefficient: day.coefficient * 365.242_190_402,      symbol: "y",  name: "mean tropical year"+"s")
    static let tropicalYear     = meanTropicalYear
    static let solarYear        = meanTropicalYear
    static let siderealYear     = DurationMeasurementUnit(coefficient: day.coefficient * 365.256_363_004,      symbol: "y",  name: "sidereal year"+"s")
    static let anomalisticYear  = DurationMeasurementUnit(coefficient: day.coefficient * 365.259_636,          symbol: "y",  name: "anomalistic year"+"s")
    static let gaussianYear     = DurationMeasurementUnit(coefficient: day.coefficient * 365.256_898_3,        symbol: "y",  name: "Gaussian year"+"s")
    static let julianYear       = DurationMeasurementUnit(coefficient: day.coefficient * 365.25,               symbol: "a",  name: "Julian year"+"s")
    
    static let day              = DurationMeasurementUnit(coefficient: ephemerisDay.coefficient,               symbol: "d",  name: "day"+"s")
    static let ephemerisDay     = DurationMeasurementUnit(coefficient: hour.coefficient * 24,                  symbol: "d",  name: "ephemeris day"+"s")
    static let meanSolarDay     = DurationMeasurementUnit(coefficient: second.coefficient * 86_400.002,        symbol: "d",  name: "mean solar day"+"s")
    
    static let hour             = DurationMeasurementUnit(coefficient: minute.coefficient * 60,                symbol: "h",  name: "hour"+"s")
    static let minute           = DurationMeasurementUnit(coefficient: second.coefficient * 60,                symbol: "m",  name: "minute"+"s")
    static let second           = DurationMeasurementUnit(coefficient: 1,                                      symbol: "s",  name: "second"+"s")
    
    static let decisecond       = DurationMeasurementUnit(coefficient: second.coefficient / 10,                symbol: "ds", name: "decisecond"+"s")
    static let centisecond      = DurationMeasurementUnit(coefficient: second.coefficient / 100,               symbol: "cs", name: "centisecond"+"s")
    static let millisecond      = DurationMeasurementUnit(coefficient: second.coefficient / 1_000,             symbol: "ms", name: "millisecond"+"s")
    static let microsecond      = DurationMeasurementUnit(coefficient: second.coefficient / 1_000_000,         symbol: "μs", name: "microsecond"+"s")
    static let nanosecond       = DurationMeasurementUnit(coefficient: second.coefficient / 1_000_000_000,     symbol: "ns", name: "nanosecond"+"s")
    static let picosecond       = DurationMeasurementUnit(coefficient: second.coefficient / 1_000_000_000_000, symbol: "ps", name: "picosecond"+"s")
}



public extension DurationMeasurementUnit {
    static let week = DurationMeasurementUnit(coefficient: day.coefficient * 7, symbol: "w", name: "week"+"s")
}
