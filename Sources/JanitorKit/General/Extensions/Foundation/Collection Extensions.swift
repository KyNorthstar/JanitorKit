//
//  Collection Extensions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-08-17.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



public extension Collection {
    
    func mapToSet<ElementOfResult>(_ mapper: (Element) -> ElementOfResult) -> Set<ElementOfResult> {
        var result = Set<ElementOfResult>(minimumCapacity: count)
        
        forEach { element in
            result.insert(mapper(element))
        }
        
        return result
    }
    
    
    func forEachIgnoringReturn<Ignored>(_ processor: (Element) throws -> Ignored) rethrows {
        for element in self {
            _ = try processor(element)
        }
    }
}



public extension RangeReplaceableCollection {
    
    @discardableResult
    mutating func removeFirstOrNil() -> Element? {
        return isEmpty ? nil : removeFirst()
    }
    
    
    mutating func consumeEach(_ consumer: (Element) throws -> Void) rethrows {
        while let element = self.removeFirstOrNil() {
            try consumer(element)
        }
    }
}



public extension BidirectionalCollection {
    /// Returns a subsequence from the position of the predicated element to the end of the collection.
    ///
    /// The first time the given predicate retuns `true`, that element and all elements after it are selected as the first in the returned subsequence.
    /// If the given predicate never returns `true`, then the whole collection is returned.
    ///
    /// - Parameter predicate: Finds the element at which to start the resulting subsequence
    ///
    /// - Returns: A subsequence starting at the found position.
    func suffix(startingFrom predicate: (Element) throws -> Bool) rethrows -> SubSequence { // TODO: Test
        guard let suffixStartIndex = try lastIndex(where: predicate) else {
            return self[...]
        }
        
        return suffix(from: suffixStartIndex)
    }
}
