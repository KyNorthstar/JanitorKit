//
//  BinaryDataUnit.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-26.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



public struct BinaryDataUnit: LinearMeasurementUnit {
    
    public static var base = BinaryDataUnit.byte
    
    public var coefficient: Value
    public var symbol: String
    public var name: PluralizableString
}



public extension BinaryDataUnit {
    static let byte = BinaryDataUnit(coefficient: 1, symbol: "B", name: "byte"+"s")
    static let octet = byte
    
    static let kilobyte  = BinaryDataUnit(coefficient:      byte.coefficient * 1000, symbol: "KB", name: "kilobyte"+"s")
    static let megabyte  = BinaryDataUnit(coefficient:  kilobyte.coefficient * 1000, symbol: "MB", name: "megabyte"+"s")
    static let gigabyte  = BinaryDataUnit(coefficient:  megabyte.coefficient * 1000, symbol: "GB", name: "gigabyte"+"s")
    static let terabyte  = BinaryDataUnit(coefficient:  gigabyte.coefficient * 1000, symbol: "TB", name: "terabyte"+"s")
    static let petabyte  = BinaryDataUnit(coefficient:  terabyte.coefficient * 1000, symbol: "PB", name: "petabyte"+"s")
    static let exabyte   = BinaryDataUnit(coefficient:  petabyte.coefficient * 1000, symbol: "EB", name: "exabyte"+"s")
    static let zettabyte = BinaryDataUnit(coefficient:   exabyte.coefficient * 1000, symbol: "ZB", name: "zettabyte"+"s")
    static let yottabyte = BinaryDataUnit(coefficient: zettabyte.coefficient * 1000, symbol: "YB", name: "yottabyte"+"s")
    
    static let kibibyte = BinaryDataUnit(coefficient:     byte.coefficient * 1024, symbol: "KiB", name: "kibibyte"+"s")
    static let mebibyte = BinaryDataUnit(coefficient: kibibyte.coefficient * 1024, symbol: "MiB", name: "mebibyte"+"s")
    static let gibibyte = BinaryDataUnit(coefficient: mebibyte.coefficient * 1024, symbol: "GiB", name: "gibibyte"+"s")
    static let tebibyte = BinaryDataUnit(coefficient: gibibyte.coefficient * 1024, symbol: "TiB", name: "tebibyte"+"s")
    static let pebibyte = BinaryDataUnit(coefficient: tebibyte.coefficient * 1024, symbol: "PiB", name: "pebibyte"+"s")
    static let exbibyte = BinaryDataUnit(coefficient: pebibyte.coefficient * 1024, symbol: "EiB", name: "exbibyte"+"s")
    static let zebibyte = BinaryDataUnit(coefficient: exbibyte.coefficient * 1024, symbol: "ZiB", name: "zebibyte"+"s")
    static let yobibyte = BinaryDataUnit(coefficient: zebibyte.coefficient * 1024, symbol: "YiB", name: "yobibyte"+"s")
}



public extension BinaryDataUnit {
    static let bit = BinaryDataUnit(coefficient: byte.coefficient / 8, symbol: "b", name: "bit"+"s")
    
    static let kilobit  = BinaryDataUnit(coefficient:      bit.coefficient * 1000, symbol: "Kb", name: "kilobit"+"s")
    static let megabit  = BinaryDataUnit(coefficient:  kilobit.coefficient * 1000, symbol: "Mb", name: "megabit"+"s")
    static let gigabit  = BinaryDataUnit(coefficient:  megabit.coefficient * 1000, symbol: "Gb", name: "gigabit"+"s")
    static let terabit  = BinaryDataUnit(coefficient:  gigabit.coefficient * 1000, symbol: "Tb", name: "terabit"+"s")
    static let petabit  = BinaryDataUnit(coefficient:  terabit.coefficient * 1000, symbol: "Pb", name: "petabit"+"s")
    static let exabit   = BinaryDataUnit(coefficient:  petabit.coefficient * 1000, symbol: "Eb", name: "exabit"+"s")
    static let zettabit = BinaryDataUnit(coefficient:   exabit.coefficient * 1000, symbol: "Zb", name: "zettabit"+"s")
    static let yottabit = BinaryDataUnit(coefficient: zettabit.coefficient * 1000, symbol: "Yb", name: "yottabit"+"s")
    
    static let kibibit = BinaryDataUnit(coefficient:     bit.coefficient * 1024, symbol: "Kib", name: "kibibit"+"s")
    static let mebibit = BinaryDataUnit(coefficient: kibibit.coefficient * 1024, symbol: "Mib", name: "mebibit"+"s")
    static let gibibit = BinaryDataUnit(coefficient: mebibit.coefficient * 1024, symbol: "Gib", name: "gibibit"+"s")
    static let tebibit = BinaryDataUnit(coefficient: gibibit.coefficient * 1024, symbol: "Tib", name: "tebibit"+"s")
    static let pebibit = BinaryDataUnit(coefficient: tebibit.coefficient * 1024, symbol: "Pib", name: "pebibit"+"s")
    static let exbibit = BinaryDataUnit(coefficient: pebibit.coefficient * 1024, symbol: "Eib", name: "exbibit"+"s")
    static let zebibit = BinaryDataUnit(coefficient: exbibit.coefficient * 1024, symbol: "Zib", name: "zebibit"+"s")
    static let yobibit = BinaryDataUnit(coefficient: zebibit.coefficient * 1024, symbol: "Yib", name: "yobibit"+"s")
}



public extension BinaryDataUnit {
    static let nibble = BinaryDataUnit(coefficient: byte.coefficient / 2, symbol: "nibble", name: "nibble"+"s")
    static let nybble = nibble
    static let nyble = nibble
    static let tetrade = nibble
    static let quartet = nibble
}
