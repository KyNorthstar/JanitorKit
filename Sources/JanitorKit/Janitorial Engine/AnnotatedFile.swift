//
//  AnnotatedFile.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-08-03.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation

import SimpleLogging



/// A file which is annotated with some of its attributes
public struct AnnotatedFile {
    
    /// The URL of the file
    public let url: URL
    
    /// The size of the file's data
    public let size: DataSize
    
    /// The age of the file
    public let age: Age
}



public extension AnnotatedFile {
    init?(_ url: URL, fileManager: FileManager = .default) {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.actualPath)
            
            guard let sizeInBytes = attributes[.size] as? UInt else {
                return nil
            }
            let size = DataSize(value: sizeInBytes, unit: .byte)
            
            guard let age = url.userSpecifiedAge(using: attributes) else {
                return nil
            }
            
            self.init(url: url, size: size, age: age)
        }
        catch {
            log(error: error)
            return nil
        }
    }
}



// MARK: - Conformance

extension AnnotatedFile: Hashable { }



extension AnnotatedFile: CustomStringConvertible {
    public var description: String {
        "\(size.bestDescription)\t •\t\(age.converted(to: .day)) old • \(url.path)"
    }
}
