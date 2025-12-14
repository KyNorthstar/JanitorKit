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
    
    
    /// ``compactMap`` but it returns a `Set` instead of an `Array`
    ///
    /// - Parameter mapper: Takes in each element of this collection, and either returns a transformed version of it, or `nil`. When this returns `nil`, that value won't be in the final set.
    /// - Returns: A set containing all elements successfully transformed by `mapper`, without any which were transformed to `nil`
    func compactMapToSet<ElementOfResult>(_ mapper: (Element) -> ElementOfResult?) -> Set<ElementOfResult> {
        let originalCount = self.count
        var result = Set<ElementOfResult>(minimumCapacity: originalCount) // Start out pessimistic and assume it'll take the max possible memory
        
        for element in self {
            guard let mapped = mapper(element) else { continue }
            result.insert(mapped)
        }
        
        if result.count == originalCount {
            // if our pessimism was correct, return the full set
            return result
        }
        else {
            // if we were overly-pessimistic (the mapped set is a smaller count than the original collection),
            // re-allocate a set of the exact size we need
            return Set(result)
        }
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
