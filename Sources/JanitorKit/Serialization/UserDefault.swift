//
//  UserDefault.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-19.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation
import SwiftUI



@propertyWrapper
public struct UserDefault<Value>: DynamicProperty where Value: Codable {
    let defaultValue: Value
    let key: String
    let userDefaults: UserDefaults
    private var observerShim: ObserverShim! = nil
    
    
    init(wrappedValue defaultValue: Value, _ key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
        
        if !isSerialized() {
            setValue(defaultValue)
        }
        
        self.observerShim = ObserverShim(*self)
    }
    
    
    public var wrappedValue: Value {
        get {
            return value()
        }
        nonmutating set {
            setValue(newValue)
        }
    }
    
    
    private func setValue(_ newValue: Value) {
        guard let newString = try? newValue.jsonString() else {
            assertionFailure("Could not create JSON string out of the new value; preserving existing defaults")
            return
        }
        userDefaults.set(newString, forKey: key)
        userDefaults.synchronize()
    }
    
    
    private func value() -> Value {
        if let existingValueString = userDefaults.string(forKey: key) {
            guard let existingValue = try? Value(jsonString: existingValueString) else {
                assertionFailure("Could not parse JSON string out of the existing value; returning nil")
                return defaultValue
            }
            return existingValue
        }
        else {
            return defaultValue
        }
    }
    
    
    private func isSerialized() -> Bool {
        userDefaults.synchronize()
        return nil != userDefaults.string(forKey: key)
    }
    
    
    
    private class ObserverShim: NSObject {
        let parent: Pointer<UserDefault>
        
        init(_ parent: Pointer<UserDefault>) {
            self.parent = parent
            
            super.init()
            
            parent.pointee.userDefaults.addObserver(self, forKeyPath: parent.pointee.key, options: .new, context: nil)
        }
        
        
        deinit {
            parent.pointee.userDefaults.removeObserver(self, forKeyPath: parent.pointee.key)
        }
        
        
        override func observeValue(forKeyPath _: String?, of _: Any?, change _: [NSKeyValueChangeKey : Any]?, context _: UnsafeMutableRawPointer?) {
            parent.pointee.update()
        }
    }
}
