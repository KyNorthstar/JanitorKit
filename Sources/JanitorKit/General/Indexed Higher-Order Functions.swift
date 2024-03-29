//
//  Indexed Higher-Order Functions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-26.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



public extension Collection {
    func mapIndexed<NewType>(_ mapper: (_ index: Index, _ element: Element) -> NewType) -> [NewType] {
        
        var result = [NewType]()
        result.reserveCapacity(count)
        
        forEachIndexed { index, element in
            result.append(mapper(index, element))
        }
        
        return result
    }
    
    
    func forEachIndexed(_ processor: (_ index: Index, _ element: Element) -> Void) {
        for index in indices {
            processor(index, self[index])
        }
    }
}
