//
//  Collection.map + concurrency.swift
//  JanitorKit
//
//  Created by Ky on 2024-08-20.
//

import Foundation



// 👋🏽 if you can find a way to rewrite this without as much repeated boilerplate, please do!
// and We would be really grateful if you could
public extension Collection where Element: Sendable {
    
    /// Returns an array containing the results of mapping the given closure over the sequence's elements, using a separate task for each such conversion.
    ///
    /// In this example, `map` is used first to convert the names in the array to lowercase strings and then to count their characters.
    ///
    /// ```swift
    /// let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    /// let favoriteColors = await cast.map { await lookup(.favoriteColor, byName: $0) }
    /// // favoriteColors == ["green", "burgundy", "blue", "red"]
    /// ```
    ///
    /// - Parameter transform: An asynchronous mapping closure; accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    ///                        This is automatically placed into a new ``Task``; you need not worry about creating a new `Task` yourself
    /// - Returns: An array containing the transformed elements of this sequence.
    func map<NewValue>(async transform: sending @escaping (Element) async -> NewValue) async -> [NewValue] {
        let count = self.count
        
        guard count > 0 else {
            return []
        }
        
        guard count > 1 else {
            return [await transform(first!)]
        }
        
        return await withTaskGroup(of: Void.self) { group in
            var resultArray = ContiguousArray<NewValue?>(repeating: nil, count: count)
            
            for (index, element) in self.enumerated() {
                group.addTask {
                    resultArray[index] = await transform(element)
                }
            }
            
            await group.waitForAll()
            
            // Gotta map it instead of cast it because this is the only way Swift lets me create an empty array and then fill it randomly
            return resultArray.map({ $0! }) // using parentheses here without a parameter label guarantees that it calls the library function rather than this one
        }
    }
    
    
    /// Returns an array containing the results of mapping the given closure over the sequence's elements, using a separate task for each such conversion.
    ///
    /// In this example, `map` is used first to convert the names in the array to lowercase strings and then to count their characters.
    ///
    /// ```swift
    /// let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    /// let favoriteColors = await cast.map { await lookup(.favoriteColor, byName: $0) }
    /// // favoriteColors == ["green", "burgundy", "blue", "red"]
    /// ```
    ///
    /// - Parameter transform: An asynchronous mapping closure; accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    ///                        This is automatically placed into a new ``Task``; you need not worry about creating a new `Task` yourself
    /// - Returns: An array containing the transformed elements of this sequence.
    func map<NewValue>(async transform: sending @escaping (Element) async -> NewValue) async -> [NewValue]
    where Self.Index == ContiguousArray<NewValue>.Index
    {
        let count = self.count
        
        guard count > 0 else {
            return []
        }
        
        guard count > 1 else {
            return [await transform(first!)]
        }
        
        return await withTaskGroup(of: Void.self) { group in
            var resultArray = ContiguousArray<NewValue?>(repeating: nil, count: count)
            
            for index in self.indices {
                group.addTask {
                    resultArray[index] = await transform(self[index])
                }
            }
            
            await group.waitForAll()
            
            // Gotta map it instead of cast it because this is the only way Swift lets me create an empty array and then fill it randomly
            return resultArray.map({ $0! }) // using parentheses here without a parameter label guarantees that it calls the library function rather than this one
        }
    }
    
    
    
    private typealias __original__map_type<NewValue> = (_ transform: (Element) -> NewValue) -> [NewValue]
}
