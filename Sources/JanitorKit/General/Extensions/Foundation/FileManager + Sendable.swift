//
//  FileManager + Sendable.swift
//
//
//  Created by Ky on 2024-03-28.
//

import Foundation



public final class SendableFileManager: FileManager {}



extension SendableFileManager: @unchecked Sendable {}



extension FileManagerProtocol where Self == SendableFileManager {
    static var default_sendable: Self {
        FileManager.default as! Self
    }
}
