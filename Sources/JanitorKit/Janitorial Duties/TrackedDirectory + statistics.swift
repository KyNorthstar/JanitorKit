//
//  TrackedDirectory + statistics.swift
//  JanitorKit
//
//  Created by Ky on 2025-10-24.
//

import Foundation

import SimpleLogging



public extension TrackedDirectory {
    struct Stats {
        public let fileCount: UInt?
        public let oldestFile: AnnotatedFile?
        public let totalSize: Size?
    }
}



public extension TrackedDirectory {
    var currentStats: Stats { get async {
        .init(
            fileCount: currentFileCount,
            oldestFile: await currentOldestFile,
            totalSize: currentTotalSize)
    }}
}



// MARK: - Count



private extension TrackedDirectory {
    var currentFileCount: UInt? {
        do {
            return UInt(try FileManager.default.contentsOfDirectory(atPath: url.path).count)
        }
        catch {
            log(error: error)
            return nil
        }
    }
}



// MARK: - Age



private extension TrackedDirectory {
    var currentOldestFile: AnnotatedFile? { get async {
        await self.annotatedContents()
            .max { lhs, rhs in
                lhs.age < rhs.age
            }
    }}
}



// MARK: - Size

public extension TrackedDirectory {
    /// Data size information about a tracked directory
    struct Size {
        public let absoluteValue: DataSize
        public let quota: DataSize
    }
}



extension TrackedDirectory.Size: Equatable {
    
}



public extension TrackedDirectory.Size {
    var quotaPercentage: CGFloat {
        absoluteValue.convertingToBase.value / quota.convertingToBase.value
    }
}



private extension TrackedDirectory {
    
    var currentTotalSize: Size? {
        guard let dataSize = url.annotated?.size else { return nil }
        return Size(absoluteValue: dataSize, quota: largestAllowedTotalSize)
    }
    
    
    /// The current total size of this tracked directory, formatted ready to present to the user
    var currentTotalSizeFormattedForUser: String {
        guard let currentTotalSize else {
            return "??? MB"
        }
        
        let quotaPercentage = currentTotalSize.quotaPercentage
        let quotaPercentDecimalPlaces: ClosedRange<Int> = if case 0 ... 0.05 = quotaPercentage {
            1...1
        }
        else {
            0...0
        }
        
        return "\(currentTotalSize.absoluteValue.bestDescription) / \(currentTotalSize.quota.bestDescription) (\(quotaPercentage.percentFormat(decimalPlaces: quotaPercentDecimalPlaces)))"
    }
}


// MARK: Formatting



package extension BinaryFloatingPoint {
    func percentFormat<DecimalPlaces>(decimalPlaces: DecimalPlaces = 0...0) -> String
    where DecimalPlaces: RangeExpression,
          DecimalPlaces.Bound == Int
    {
        FloatingPointFormatStyle<Self>.Percent()
            .decimalSeparator(strategy: .automatic)
            .precision(.fractionLength(decimalPlaces))
            .format(self)
    }
}
