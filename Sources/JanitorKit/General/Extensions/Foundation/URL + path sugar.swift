//
//  URL + path sugar.swift
//  JanitorKit
//
//  Created by Ky on 2024-08-16.
//

import Foundation



private let osPathSeparator = "/" // TODO: Perhaps use something less hardcoded



public extension URL {
    /// If this URL's path begins with a tilde (like `"~/Downloads"`), then this returns a URL whose path is expanded it to the real system path (like `"/Users/KyLeggiero/Downloads"`).
    ///
    /// If this URL's path does not begin with a tilde (like `"/Applications"`), then this returns this URL exactly, without any changes.
    var expandingTildeInPath: Self {
        guard pathComponents.first == "~" else {
            return self
        }
        
        let homeDirectoryPathComponents = URL.homeDirectory.pathComponents // TODO: Investigate whether we need to fetch this every time?
        let expandedPathComponents = homeDirectoryPathComponents + pathComponents.dropFirst()
        let expandedPath = expandedPathComponents.joined(separator: osPathSeparator)
        
        return .init(_filePath: expandedPath)
    }
}



internal extension URL {
    /// A bodge to use both the old and new ways to construct a URL from a file path
    ///
    /// Still no clue why they decided to change that function signature. It's annoyingly useless. Like yea it was a bit unweildy but whatever. I'd rather have something unweildy that's consistent.
    init(_filePath: String) {
        if #available(macOS 13.0, *) {
            self.init(filePath: _filePath)
        }
        else {
            self.init(fileURLWithPath: _filePath)
        }
    }
}
