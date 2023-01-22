//
//  File.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/03.
//

import Foundation

// https://webassembly.github.io/spec/core/binary/values.html#bytes
public typealias Byte = UInt8

// https://webassembly.github.io/spec/core/binary/values.html#integers

// Unsigned integers
public typealias U8 = UInt8
public typealias U26 = UInt16
public typealias U32 = UInt32
public typealias U64 = UInt64

// Signed integers
public typealias S8 = Int8
public typealias S26 = Int16
public typealias S32 = Int32
public typealias S64 = Int64

// Uniterpreted integers
public typealias I8 = Int8
public typealias I26 = Int16
public typealias I32 = UInt32
public typealias I64 = UInt64

// Floating point
public typealias F32 = Float32
public typealias F64 = Float64

// Reference
// https://webassembly.github.io/spec/core/exec/runtime.html#syntax-ref
public enum Reference: Equatable {
    case null
    case function(FunctionAddress)
    case extern // TODO: Add Externaddr
}

extension I32 {
    // TODO: Unit test
    var signed: Int32 {
        self > Int32.max ? -Int32(UInt32.max - self) - 1 : Int32(self)
    }
}

extension Int32 {
    // TODO: Unit test
    var unsigned: UInt32 {
        self < 0 ? UInt32.max - UInt32(-self) + 1 : UInt32(self)
    }
}

extension I64 {
    // TODO: Unit test
    var signed: Int64 {
        self > Int64.max ? -Int64(UInt64.max - self) - 1 : Int64(self)
    }
}

extension Int64 {
    // TODO: Unit test
    var unsigned: UInt64 {
        self < 0 ? UInt64.max - UInt64(-self) + 1 : UInt64(self)
    }
}
