//
//  Value.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import Foundation

// https://webassembly.github.io/spec/core/exec/runtime.html#values
public enum Value: Equatable {
    case i32(I32)
    case i64(I64)
    case f32(F32)
    case f64(F64)
    case vector
//    case reference
    
    var type: ValueType {
        switch self {
        case .i32: return .number(.i32)
        case .i64: return .number(.i64)
        case .f32: return .number(.f32)
        case .f64: return .number(.f64)
        case .vector: return .vector(.v128)
        }
    }
    
    init(value: I32) {
        self = .i32(value)
    }

    init(value: I64) {
        self = .i64(value)
    }
    
    init(value: F32) {
        self = .f32(value)
    }
    
    init(value: F64) {
        self = .f64(value)
    }

    init(type: ValueType) {
        switch type {
        case let .number(numberType):
            switch numberType {
            case .i32:
                self = .i32(0)
            case .i64:
                self = .i64(0)
            case .f32:
                self = .f32(0)
            case .f64:
                self = .f64(0)
            }
        case .vector, .reference:
            fatalError("Not supported yet")
        }
    }
    
    init(type: ValueType,
         bytes: [Byte]) {
        switch type {
        case let .number(numberType):
            switch numberType {
            case .i32:
                self = .i32(Data(bytes).withUnsafeBytes { $0.load( as: I32.self ) })
            case .i64:
                self = .i64(Data(bytes).withUnsafeBytes { $0.load( as: I64.self ) })
            case .f32:
                self = .f32(Data(bytes).withUnsafeBytes { $0.load( as: F32.self ) })
            case .f64:
                self = .f64(Data(bytes).withUnsafeBytes { $0.load( as: F64.self ) })
            }
        case .vector, .reference:
            fatalError("Not supported yet")
        }
    }
}

extension Value {
    var defaultValue: Self {
        switch self {
        case .i32:
            return .i32(0)
        case .i64:
            return .i64(0)
        case .f32:
            return .f32(0)
        case .f64:
            return .f64(0)
        case .vector:
            return .vector
        }
    }
    
    var asI32: I32? {
        switch self {
        case let .i32(value):
            return value
        case .i64, .f32, .f64, .vector:
            return nil
        }
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#results
enum Result {
    case value(Value)
    case trap
}

