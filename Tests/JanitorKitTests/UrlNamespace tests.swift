//
//  Test 2.swift
//  JanitorKit
//
//  Created by Ky on 2024-09-05.
//

import Foundation
import Testing

import JanitorKit



struct UrlNamespace_tests {
    
    @Test func searchPath_fileManager() async throws {
//        TODO
    }
    
    
    @Test func searchPath_generic() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        #expect(URL.User.searchPath(for: .generic(.root)) == ["/Users"])
    }
}
