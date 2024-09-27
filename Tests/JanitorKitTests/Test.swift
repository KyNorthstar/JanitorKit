//
//  Test.swift
//  JanitorKit
//
//  Created by Ky on 2024-08-22.
//

import Testing
import JanitorKit



struct Collection_map_async {

    @Test
    func zeroItems() async throws {
        #expect((await (0..<0).map { await Scope(value: "Item #\($0) shouldn't exist") }).isEmpty)
    }
}



private actor Scope<Value> {
    
    var value: Value
    
    
    init(value: Value) async {
        self.value = value
    }
}
