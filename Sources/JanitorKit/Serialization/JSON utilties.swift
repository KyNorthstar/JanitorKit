//
//  JSON utilties.swift
//  JanitorKit
//
//  Created by Ky Leggiero on 2019-07-26.
//  Copyright © 2019 Ky Leggiero. All rights reserved.
//

import Foundation



// MARK: - Encoding

public extension JSONEncoder {
    static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}



public extension Encodable {
    func jsonData(with encoder: JSONEncoder = .default) throws -> Data {
        return try encoder.encode(self)
    }
    
    
    func jsonString(with encoder: JSONEncoder = .default, encoding: String.Encoding = .utf8) throws -> String {
        guard let jsonString = String(data: try jsonData(), encoding: encoding) else {
            throw JsonDataWasNotInTheProperStringEncoding(expectedEncoding: encoding)
        }
        return jsonString
    }
}



public struct JsonDataWasNotInTheProperStringEncoding: Error {
    public let expectedEncoding: String.Encoding
}



// MARK: - Decoding



public extension JSONDecoder {
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}



public extension Decodable {
    init(jsonData: Data, decoder: JSONDecoder = .default) throws {
        self = try decoder.decode(Self.self, from: jsonData)
    }
    
    
    init(jsonString: String, decoder: JSONDecoder = .default, stringEncoding: String.Encoding = .utf8) throws {
        guard let jsonData = jsonString.data(using: stringEncoding) else {
            throw JsonStringWasNotInTheProperStringEncoding(expectedEncoding: stringEncoding)
        }
        try self.init(jsonData: jsonData, decoder: decoder)
    }
}



public struct JsonStringWasNotInTheProperStringEncoding: Error {
    public let expectedEncoding: String.Encoding
}
