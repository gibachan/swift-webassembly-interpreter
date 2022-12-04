//
//  DataExtension.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/10.
//

import Foundation

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
    
    mutating func consume(bytes: Int) -> Data? {
        guard self.count >= bytes else {
            self = Data()
            return nil
        }
        let consumed = prefix(bytes)
        let remaining = suffix(count - bytes)
        self = remaining
        return consumed
    }
    
    var uint8: UInt8? {
        guard count == 1 else {
            return nil
        }
        return withUnsafeBytes { $0.load( as: UInt8.self ) }
    }
    
    var uint16: UInt16? {
        guard count == 2 else {
            return nil
        }
        return withUnsafeBytes { $0.load( as: UInt16.self ) }
    }
    
    var uint32: UInt32? {
        guard count == 4 else {
            return nil
        }
        return withUnsafeBytes { $0.load( as: UInt32.self ) }
    }
    
    var uint64: UInt64? {
        guard count == 8 else {
            return nil
        }
        return withUnsafeBytes { $0.load( as: UInt64.self ) }
    }
}
