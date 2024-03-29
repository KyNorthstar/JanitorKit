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
    
    
    func convertToBase(value: Value) -> Value
    func convertFromBase(value: Value) -> Value
}



public extension MeasurementUnit {
    typealias Value = CGFloat.NativeType
}



// MARK: - LinearMeasurementUnit

public protocol LinearMeasurementUnit: MeasurementUnit {
    var coefficient: Value { get }
}



public extension LinearMeasurementUnit {
    
    func convertToBase(value: Value) -> Value {
        return value * coefficient
    }
    
    
    func convertFromBase(value: Value) -> Value {
        return value / coefficient
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
