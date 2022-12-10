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
    case vector
//    case reference
    
    var type: ValueType {
        switch self {
        case .i32: return .number(.i32)
        case .i64: return .number(.i64)
        case .vector: return .vector(.v128)
        }
    }
    
    init(value: I32) {
        self = .i32(value)
    }

    init(value: I64) {
        self = .i64(value)
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
                fatalError("Not supported yet")
            case .f64:
                fatalError("Not supported yet")
            }
        case .vector, .reference:
            fatalError("Not supported yet")
        }
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#results
enum Result {
    case value(Value)
    case trap
}

