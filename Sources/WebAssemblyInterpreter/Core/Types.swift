//
//  Types.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/13.
//

import Foundation

// https://webassembly.github.io/spec/core/binary/types.html#number-types
enum NumberType: Byte {
    case i32 = 0x7F
    case i64 = 0x7E
    case f32 = 0x7D
    case f64 = 0x7C
}

extension NumberType: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .i32:
            return "i32"
        case .i64:
            return "i64"
        case .f32:
            return "f32"
        case .f64:
            return "f64"
        }
    }
}

// https://webassembly.github.io/spec/core/binary/types.html#vector-types
enum VectorType: Byte {
    case v128 = 0x7B
}

extension VectorType: CustomDebugStringConvertible {
    var debugDescription: String {
        "Vector Type"
    }
}

// https://webassembly.github.io/spec/core/binary/types.html#reference-types
enum ReferenceType: Byte {
    case function = 0x70
    case extern = 0x6F
}

extension ReferenceType: CustomDebugStringConvertible {
    var debugDescription: String {
        "Vector Type"
    }
}

// https://webassembly.github.io/spec/core/binary/types.html#value-types
enum ValueType: Equatable {
    case number(NumberType)
    case vector(VectorType)
    case reference(ReferenceType)
    case referenceNull
}

extension ValueType {
    static func from(byte: Byte) -> Self? {
        if let numberType = NumberType(rawValue: byte) {
            return .number(numberType)
        }
        if let vectorType = VectorType(rawValue: byte) {
            return .vector(vectorType)
        }
        if let referenceType = ReferenceType(rawValue: byte) {
            return .reference(referenceType)
        }
        return nil
    }
}

extension ValueType: CustomDebugStringConvertible {
    var debugDescription: String {
        let type: String
        switch self {
        case let .number(_type):
            type = "Number Type: \(_type)"
        case .vector:
            type = "Vector Type"
        case let .reference(_type):
            type = "Reference Type: \(_type)"
        case .referenceNull:
            type = "Reference Null Type"
        }
        return [
            "[Value Type] \(type)"
        ].joined(separator: ", ")
    }
}


// https://webassembly.github.io/spec/core/binary/types.html#result-types
struct ResultType: Equatable {
    let valueTypes: Vector<ValueType>
}

extension ResultType: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Result Type] Value type count: \(valueTypes.length)",
            valueTypes.elements.map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/types.html#function-types
struct FunctionType: Equatable {
    static let id: Byte = 0x60
    
    let parameterTypes: ResultType
    let resultTypes: ResultType
}

extension FunctionType: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Function Type] ID: \(Self.id)",
            "\(parameterTypes)",
            "\(resultTypes)"
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/types.html#limits
enum Limits: Equatable {
    case min(n: U32)
    case minMax(n: U32, m: U32)
    
    enum LimitsType: Byte {
    case min = 0x00
    case minMax = 0x01
    }
    
    var type: LimitsType {
        switch self {
        case .min: return .min
        case .minMax: return .minMax
        }
    }
    
    var min: U32 {
        switch self {
        case let .min(n): return n
        case let .minMax(n, _): return n
        }
    }
    
    var max: U32? {
        switch self {
        case .min: return nil
        case let .minMax(_, m): return m
        }
    }
}

// https://webassembly.github.io/spec/core/binary/types.html#memory-types
typealias MemoryType = Limits

// https://webassembly.github.io/spec/core/binary/types.html#memory-types
struct TableType: Equatable {
    let referenceType: ReferenceType
    let limits: Limits
}

// https://webassembly.github.io/spec/core/binary/types.html#global-types
struct GlobalType: Equatable {
    let valueType: ValueType
    let mutability: Mutability
    
    enum Mutability: Byte {
        case const = 0x00
        case `var` = 0x01
    }
}
