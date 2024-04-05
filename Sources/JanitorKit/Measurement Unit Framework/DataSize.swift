//
//  DataSize.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-19.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



/// The size of some data, such as bytes, nibbles, gigabytes, mebibytes, etc.
public typealias DataSize = Measurement<BinaryDataUnit>



// MARK: - CaseIterable

extension BinaryDataUnit: CaseIterable {
    
    public typealias AllCases = [BinaryDataUnit]
    
    
    
    public static let `default`: Self = .mebibyte
    
    
    public static let allCases: AllCases = [
        .byte,
        
        .bit,
        .nibble,
        
        .yottabyte,
        .zettabyte,
        .exabyte,
        .petabyte,
        .terabyte,
        .gigabyte,
        .megabyte,
        .kilobyte,
        
        .yottabit,
        .zettabit,
        .exabit,
        .petabit,
        .terabit,
        .gigabit,
        .megabit,
        
        .kilobit,
        .yobibyte,
        .zebibyte,
        .exbibyte,
        .pebibyte,
        .tebibyte,
        .gibibyte,
        .mebibyte,
        
        .kibibyte,
        .yobibit,
        .zebibit,
        .exbibit,
        .pebibit,
        .tebibit,
        .gibibit,
        .mebibit,
        .kibibit,
    ]
    
    
    public static let commonFileSizeCases: AllCases = [
        .kibibyte,
        .mebibyte,
        .gibibyte,
        .tebibyte
    ]
    
    
    public static let commonSiFileSizeCases: AllCases = [
        .kilobyte,
        .megabyte,
        .gigabyte,
        .terabyte
    ]
    
    
    public static let allByteCases: AllCases = [
        .byte,
        .kibibyte,
        .mebibyte,
        .gibibyte,
        .tebibyte,
        .pebibyte,
        .exbibyte,
        .zebibyte,
        .yobibyte,
    ]
    
    
    public static let allSiByteCases: AllCases = [
        .byte,
        .kilobyte,
        .megabyte,
        .gigabyte,
        .terabyte,
        .petabyte,
        .exabyte,
        .zettabyte,
        .yottabyte,
    ]
    
    
    public static let allBitCases: AllCases = [
        .bit,
        .kibibit,
        .mebibit,
        .gibibit,
        .tebibit,
        .pebibit,
        .exbibit,
        .zebibit,
        .yobibit,
    ]
    
    
    public static let allSiBitCases: AllCases = [
        .bit,
        .kilobit,
        .megabit,
        .gigabit,
        .terabit,
        .petabit,
        .exabit,
        .zettabit,
        .yottabit,
    ]
}



// MARK: - Stdlib Extensions

public extension BinaryFloatingPoint {
    var bytes:      DataSize { DataSize(value: DataSize.Value(self), unit: .byte) }
    
    var bits:       DataSize { DataSize(value: DataSize.Value(self), unit: .bit) }
    
    var nibbles:    DataSize { DataSize(value: DataSize.Value(self), unit: .nibble) }
    
    var yottabytes: DataSize { DataSize(value: DataSize.Value(self), unit: .yottabyte) }
    var zettabytes: DataSize { DataSize(value: DataSize.Value(self), unit: .zettabyte) }
    var exabytes:   DataSize { DataSize(value: DataSize.Value(self), unit: .exabyte) }
    var petabytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .petabyte) }
    var terabytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .terabyte) }
    var gigabytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .gigabyte) }
    var megabytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .megabyte) }
    var kilobytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .kilobyte) }
    
    var yottabits:  DataSize { DataSize(value: DataSize.Value(self), unit: .yottabit) }
    var zettabits:  DataSize { DataSize(value: DataSize.Value(self), unit: .zettabit) }
    var exabits:    DataSize { DataSize(value: DataSize.Value(self), unit: .exabit) }
    var petabits:   DataSize { DataSize(value: DataSize.Value(self), unit: .petabit) }
    var terabits:   DataSize { DataSize(value: DataSize.Value(self), unit: .terabit) }
    var gigabits:   DataSize { DataSize(value: DataSize.Value(self), unit: .gigabit) }
    var megabits:   DataSize { DataSize(value: DataSize.Value(self), unit: .megabit) }
    var kilobits:   DataSize { DataSize(value: DataSize.Value(self), unit: .kilobit) }
    
    var yobibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .yobibyte) }
    var zebibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .zebibyte) }
    var exbibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .exbibyte) }
    var pebibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .pebibyte) }
    var tebibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .tebibyte) }
    var gibibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .gibibyte) }
    var mebibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .mebibyte) }
    var kibibytes:  DataSize { DataSize(value: DataSize.Value(self), unit: .kibibyte) }
    
    var yobibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .yobibit) }
    var zebibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .zebibit) }
    var exbibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .exbibit) }
    var pebibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .pebibit) }
    var tebibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .tebibit) }
    var gibibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .gibibit) }
    var mebibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .mebibit) }
    var kibibits:   DataSize { DataSize(value: DataSize.Value(self), unit: .kibibit) }
}



// MARK: - Auto string

private let bitsPerByte = Int(1.bytes.converted(to: .bit).value)
private let bytesPerPrefixStep = 1.kibibytes.converted(to: .byte).value
private let bitsPerPrefixStep = 1.kibibits.converted(to: .bit).value

public extension DataSize {
    /// Finds the best way to represent this data size as a string.
    ///
    /// For example, `4,194,304 bytes` will be represented as `"4 MiB"`,
    /// `3,371,549,327.36 bytes` will be represented as `"3.14 GiB"`,
    /// `3,360 bits` will be represented as `420 bytes`,
    /// `39916801 bits` will be represented as `"38.07 Mib"` (because it's not divisible by 8)
    /// etc.
    ///
    /// ---
    ///
    /// There are some special cases where the returned output is guaranteed:
    ///
    /// |                       data size value | `.bestDescription`
    /// | -------------------------------------:|:------------------
    /// |                                     0 | `"0 bits"`
    /// |           Not a number, or non-normal | `"NaN bits"`
    /// | `> Int.max`, `< Int.min`, or infinite | `"Infinity bits"`
    var bestDescription: String {
        let bits = converted(to: .bit)
        let bitsValue = bits.value
        
        guard bitsValue != 0 else {
            return "0 bits"
        }
        
        guard bits.value.isNormal,
              !bits.value.isNaN
        else {
            return "NaN bits"
        }
        
        guard bits.value.isFinite,
              bits.value <= .init(Int.max),
              bits.value >= .init(Int.min)
        else {
            return "Infinity bits"
        }
        
        let bestUnit: Unit
        
        if Int(bits.value).isMultiple(of: bitsPerByte) {
            bestUnit = Unit
                .allByteCases
                .first_presortedShortestFirst(fitting: bits, withinStep: bytesPerPrefixStep)
                ?? .default
        }
        else {
            bestUnit = Unit
                .allBitCases
                .first_presortedShortestFirst(fitting: bits, withinStep: bitsPerPrefixStep)
                ?? .default
        }
        
        let bestConversion = converted(to: bestUnit)
        
        let numberString = Decimal.FormatStyle()
            .precision(.fractionLength(0...2))
            .format(.init(bestConversion.value))
        
        let unitString = bestUnit.symbol
        
        return "\(numberString) \(unitString)"
    }
}
