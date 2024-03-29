//
//  Array Extensions.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-28.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import SwiftUI
import PropertyWrapperProtocol



public extension Array where Element: Identifiable {
    
    subscript(_ id: Element.ID) -> Element? {
        self.firstIndex(ofElementWithId: id).map { self[$0] }
    }
    
    
    func firstIndex(ofElementWithId needleId: Element.ID) -> Index? {
        return firstIndex(where: { $0.id == needleId })
    }
    
    
    @discardableResult
    mutating func replaceOrAppend(_ changedOrNewElement: Element) -> ReplaceOrAppendResult {
        if let index = firstIndex(ofElementWithId: changedOrNewElement.id) {
            self[index] = changedOrNewElement
            return .didReplace
        }
        else {
            self.append(changedOrNewElement)
            return .didAppend
        }
    }
    
    
    @discardableResult
    mutating func remove(firstElementWithId itemId: Element.ID) -> RemoveResult<Element>? {
        if let itemIndex = firstIndex(ofElementWithId: itemId) {
            let removedElement = remove(at: itemIndex)
            return .removedSuccessfully(removedElement: removedElement)
        }
        else {
            return .noSuchElementFound
        }
    }
}



public extension Array where Element: PropertyWrapper, Element.WrappedValue: Identifiable {
    
    
    func firstIndex(ofElementWithId needleId: Element.WrappedValue.ID) -> Index? {
        return firstIndex(where: { $0.wrappedValue.id == needleId })
    }
    
}



public extension Array where Element: MutablePropertyWrapper, Element.WrappedValue: Identifiable {
    
    @discardableResult
    mutating func replaceOrAppend(value changedOrNewValue: Element.WrappedValue,
                                  newPropertyGenerator: (_ newValue: Element.WrappedValue) throws -> Element
    ) rethrows -> ReplaceOrAppendResult {
        
        if let index = firstIndex(ofElementWithId: changedOrNewValue.id) {
            self[index].wrappedValue = changedOrNewValue
            return .didReplace
        }
        else {
            self.append(try newPropertyGenerator(changedOrNewValue))
            return .didAppend
        }
    }
}



public enum ReplaceOrAppendResult {
    case didReplace
    case didAppend
}



public enum RemoveResult<Element> {
    case noSuchElementFound
    case removedSuccessfully(removedElement: Element)
}
