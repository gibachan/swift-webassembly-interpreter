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
public typealias I32 = Int32
public typealias I64 = Int64

// Floating point
public typealias F32 = Float32
public typealias F64 = Float64
