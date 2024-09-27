//
//  URL Operators.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-18.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



public extension URL {
    
    /// A URL pointing to the given file inside the directory pointed to by the given URL
    /// 
    /// For instance, if you have the URL `https://en.wikipedia.org/wiki/` and the page you want is `Swift_(programming_language)`, you can use the following:
    /// ```swift
    /// let swiftWiki = wikipediaBaseUrl / "Swift_(programming_language)"
    /// ```
    ///
    /// - Returns: A URL pointing to a file with the given name in the user's home
    /// - Parameters:
    ///   - lhs: The existng URL
    ///   - rhs: The name of the file or directory within the existing URL's path
    static func / (lhs: URL, rhs: String) -> URL {
        return lhs.appendingPathComponent(rhs)
    }
    
    
    /// Changes the given URL to point to the given file inside the directory pointed to by the given URL
    ///
    /// For instance, if you have the URL `https://en.wikipedia.org/wiki/` and the page you want is `Swift_(programming_language)`, you can use the following:
    /// ```swift
    /// wikipediaBaseUrl =/ "Swift_(programming_language)"
    /// ```
    ///
    /// - Returns: A URL pointing to a file with the given name in the user's home
    /// - Parameters:
    ///   - lhs: The existng URL
    ///   - rhs: The name of the file or directory within the existing URL's path
    static func /= (lhs: inout URL, rhs: String) {
        lhs = lhs / rhs
    }
}



/// A URL pointing to the given file relative to the user home.
///
/// For instance, for `~/Google Drive/File.txt` you would use this:
/// ```swift
/// let file = ~/ "Google Drive" / "File.txt"
/// ```
///
/// - Parameter rhs: The name of the file or directory inside the user's home
/// - Returns: A URL pointing to a file with the given name in the user's home
prefix func ~/ (rhs: String) -> URL {
    URL.homeDirectory / rhs
}



prefix operator ~/
