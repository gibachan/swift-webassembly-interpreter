//
//  BinarySource.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/17.
//

import Foundation

final class BinarySource {
    private let bytes: [Element]
    private(set) var currentIndex: Int
    
    init(data: Data) {
        self.bytes = data.map { $0 }
        self.currentIndex = bytes.startIndex
    }
}

extension BinarySource: CustomDebugStringConvertible {
    var debugDescription: String {
        return stride(from: 0, to: bytes.count, by: 2)
            .map { Array(bytes[$0..<$0 + 2]) }
            .map { $0.map { $0.hex }
                .joined() }
            .joined(separator: " ")
    }
}

extension BinarySource: Collection {
    typealias Element = Byte
    typealias Index = Int

    var startIndex: Index { return bytes.startIndex }
    var endIndex: Index { return bytes.endIndex }

    subscript (position: Index) -> Element {
        get {
            return bytes[position]
        }
    }

    func index(after i: Index) -> Index {
        precondition(i < endIndex, "Can't advance beyond endIndex")
        return i + 1
    }
}

extension BinarySource {
    var current: Element? {
        guard currentIndex >= startIndex, currentIndex < endIndex else {
            return nil
        }
        return bytes[currentIndex]
    }
    
    var remaining: Int {
        endIndex - currentIndex
    }
    
    func moveToStart() {
        currentIndex = startIndex
    }
    
    func move(_ count: Index) {
        let position = currentIndex + count
        precondition(position < startIndex || position < endIndex, "Index is out of bounds")
        currentIndex += count
    }
    
    @discardableResult
    func consume(_ count: Index) -> Data? {
        let position = currentIndex + count
        guard position >= startIndex && position <= endIndex else {
            return nil
        }
        let consumed = Data(bytes[currentIndex..<position])
        currentIndex += count
        return consumed
    }
}

extension BinarySource {
    @discardableResult
    func peek() -> Byte? {
        let nextPosition = currentIndex + 1
        guard nextPosition < endIndex else {
            return nil
        }
        return bytes[nextPosition]
    }
    
    @discardableResult
    func consume() -> Byte? {
        let byteCount = 1
        guard let data = consume(byteCount) else {
            return nil
        }
        
        if let value = data.uint8 {
            return value
        } else {
            move(-byteCount)
            return nil
        }
    }
    
    // TODO: Unit test
    @discardableResult
    func consumeU32() -> UInt32? {
        var consumedByteCount = 0
        var bytes: [Byte] = []
        repeat {
            guard let data = consume(1),
                  let byte = data.first else {
                return nil
            }
            
            consumedByteCount += 1
            bytes.append(byte)
            
            if let value = try? UInt32(unsignedLEB128: Data(bytes)) {
                return value
            }
        } while currentIndex < bytes.endIndex
        return nil
    }
    
    // TODO: Unit test
    @discardableResult
    func consumeI32() -> I32? {
        var consumedByteCount = 0
        var bytes: [Byte] = []
        repeat {
            guard let data = consume(1),
                  let byte = data.first else {
                return nil
            }
            
            consumedByteCount += 1
            bytes.append(byte)
            
            if let value = try? Int32(signedLEB128: Data(bytes)) {
                return value
            }
        } while currentIndex < bytes.endIndex
        return nil
    }
}
