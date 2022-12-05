//
//  Instructions.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/13.
//

import Foundation

// https://webassembly.github.io/spec/core/binary/instructions.html

enum Instruction {
    // Control Instructions
    // https://webassembly.github.io/spec/core/binary/instructions.html#control-instructions
    case unreachable
    case nop
    case block(BlockType)
    case loop(BlockType)
    case `if`(BlockType) // TODO: implement else instruction
    case br(LabelIndex)
    case brIf(LabelIndex)
    case call(FunctionIndex)

    // Variable Instructions
    // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
    case localGet(LocalIndex)
    case localSet(LocalIndex)
    case localTee(LocalIndex)
    case globalGet(GlobalIndex)
    case globalSet(GlobalIndex)
    
    case f32Add

    // Numeric Instructions
    // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
    case i32Const(I32)
    case i64Const
    case f32Const
    case f64Const
    
    case i32Eq
    case i32GeU
    
    case i32Add
    case i32Sub
    case i32Mul

    // Expressions
    // https://webassembly.github.io/spec/core/binary/instructions.html#expressions
    case end
}

extension Instruction {
    enum ID: Byte {
        // Control Instructions
        // https://webassembly.github.io/spec/core/binary/instructions.html#control-instructions
        case unreachable = 0x00
        case nop = 0x01
        case block = 0x02
        case loop = 0x03
        case `if` = 0x04
        case br = 0x0C
        case brIf = 0x0D
        case call = 0x10
        
        // Variable Instructions
        // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
        case localGet = 0x20
        case localSet = 0x21
        case localTee = 0x22
        case globalGet = 0x23
        case globalSet = 0x24
        
        case f32Add = 0x92

        // Numeric Instructions
        // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
        case i32Const = 0x41
        case i64Const = 0x42
        case f32Const = 0x43
        case f64Const = 0x44
        
        case i32Eq = 0x46
        case i32GeU = 0x4F
        
        case i32Add = 0x6A
        case i32Sub = 0x6B
        case i32Mul = 0x6C

        // Expressions
        // https://webassembly.github.io/spec/core/binary/instructions.html#expressions
        case end = 0x0B
    }
    
    var id: ID {
        switch self {
        case .unreachable: return .unreachable
        case .nop: return .nop
        case .block: return .block
        case .loop: return .loop
        case .if: return .if
        case .br: return .br
        case .brIf: return .brIf
        case .call: return .call
            
        case .localGet: return .localGet
        case .localSet: return .localSet
        case .localTee: return .localTee
        case .globalGet: return .globalGet
        case .globalSet: return .globalSet
            
        case .f32Add: return .f32Add
            
        case .i32Const: return .i32Const
        case .i64Const: return .i64Const
        case .f32Const: return .f32Const
        case .f64Const: return .f64Const
            
        case .i32Eq: return .i32Eq
        case .i32GeU: return .i32GeU
            
        case .i32Add: return .i32Add
        case .i32Sub: return .i32Sub
        case .i32Mul: return .i32Mul
            
        case .end: return .end
        }
    }
}

extension Instruction {
    var isBlock: Bool {
        switch self {
        case .block, .loop, .if: return true
        default: return false
        }
    }
}

// https://webassembly.github.io/spec/core/binary/instructions.html#binary-blocktype
enum BlockType {
    case empty
    case value(ValueType)
    // TODO: Support type index
    //    case typeIndex
}
    
extension BlockType {
    static var emptyByte: Byte = 0x40
}
    

// https://webassembly.github.io/spec/core/binary/instructions.html#expressions
struct Expression {
    let instructions: [Instruction]
}

extension Expression: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Expression] Instruction count: \(instructions.count)",
            instructions
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}