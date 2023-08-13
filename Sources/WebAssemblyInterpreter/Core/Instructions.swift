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
    case `if`(BlockType)
    case `else`
    case br(LabelIndex)
    case brIf(LabelIndex)
    case brTable(Vector<LabelIndex>, LabelIndex)
    case `return`
    case call(FunctionIndex)
    case callIndirect(TypeIndex, TableIndex)
    
    // Parametric Instructions
    // https://webassembly.github.io/spec/core/binary/instructions.html#parametric-instructions
    case drop
    case select

    // Variable Instructions
    // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
    case localGet(LocalIndex)
    case localSet(LocalIndex)
    case localTee(LocalIndex)
    case globalGet(GlobalIndex)
    case globalSet(GlobalIndex)
    
    case f32Add
    case f32Div
    case f64Add

    // Memory Instructions
    // https://webassembly.github.io/spec/core/binary/instructions.html#memory-instructions
    case i32Load(MemoryArgument)
    case i32Store(MemoryArgument)
    case dataDrop(DataIndex)
    
    // Numeric Instructions
    // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
    case i32Const(I32)
    case i64Const(I64)
    case f32Const
    case f64Const
    
    case i32Eqz
    case i32Eq
    case i32Ne
    case i32LtS
    case i32LtU
    case i32GtS
    case i32GtU
    case i32LeS
    case i32LeU
    case i32GeS
    case i32GeU

    case i64Eqz
    case i64Eq
    case i64Ne
    case i64LtS
    case i64LtU
    case i64GtS
    case i64GtU
    case i64LeS
    case i64LeU
    case i64GeS
    case i64GeU
    
    case i32Clz
    case i32Ctz
    case i32Popcnt
    case i32Add
    case i32Sub
    case i32Mul
    case i32DivS
    case i32DivU
    case i32RemS
    case i32RemU
    case i32And
    case i32Or
    case i32Xor
    case i32Shl
    case i32ShrS
    case i32ShrU
    case i32Rotl
    case i32Rotr

    case i64Clz
    case i64Ctz
    case i64Popcnt
    case i64Add
    case i64Sub
    case i64Mul
    case i64DivS
    case i64DivU
    case i64RemS
    case i64RemU
    case i64And
    case i64Or
    case i64Xor
    case i64Shl
    case i64ShrS
    case i64ShrU
    case i64Rotl
    case i64Rotr

    case i32Extend8S
    case i32Extend16S
    case i64Extend8S
    case i64Extend16S
    case i64Extend32S

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
        case `else` = 0x05
        case br = 0x0C
        case brIf = 0x0D
        case brTable = 0x0E
        case `return` = 0x0F
        case call = 0x10
        case callIndirect = 0x11
        
        // Parametric Instructions
        // https://webassembly.github.io/spec/core/binary/instructions.html#parametric-instructions
        case drop = 0x1A
        case select = 0x1B
        
        // Variable Instructions
        // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
        case localGet = 0x20
        case localSet = 0x21
        case localTee = 0x22
        case globalGet = 0x23
        case globalSet = 0x24
        
        case f32Add = 0x92
        case f32Div = 0x95

        case f64Add = 0xA0
        
        // Memory Instructions
        // https://webassembly.github.io/spec/core/binary/instructions.html#memory-instructions
        case i32Load = 0x28
        case i32Store = 0x36
        case dataDrop = 0xFC

        // Numeric Instructions
        // https://webassembly.github.io/spec/core/binary/instructions.html#variable-instructions
        case i32Const = 0x41
        case i64Const = 0x42
        case f32Const = 0x43
        case f64Const = 0x44

        case i32Eqz = 0x45
        case i32Eq = 0x46
        case i32Ne = 0x47
        case i32LtS = 0x48
        case i32LtU = 0x49
        case i32GtS = 0x4A
        case i32GtU = 0x4B
        case i32LeS = 0x4C
        case i32LeU = 0x4D
        case i32GeS = 0x4E
        case i32GeU = 0x4F

        case i64Eqz = 0x50
        case i64Eq = 0x51
        case i64Ne = 0x52
        case i64LtS = 0x53
        case i64LtU = 0x54
        case i64GtS = 0x55
        case i64GtU = 0x56
        case i64LeS = 0x57
        case i64LeU = 0x58
        case i64GeS = 0x59
        case i64GeU = 0x5A

        case i32Clz = 0x67
        case i32Ctz = 0x68
        case i32Popcnt = 0x69
        case i32Add = 0x6A
        case i32Sub = 0x6B
        case i32Mul = 0x6C
        case i32DivS = 0x6D
        case i32DivU = 0x6E
        case i32RemS = 0x6F
        case i32RemU = 0x70
        case i32And = 0x71
        case i32Or = 0x72
        case i32Xor = 0x73
        case i32Shl = 0x74
        case i32ShrS = 0x75
        case i32ShrU = 0x76
        case i32Rotl = 0x77
        case i32Rotr = 0x78

        case i64Clz = 0x79
        case i64Ctz = 0x7A
        case i64Popcnt = 0x7B
        case i64Add = 0x7C
        case i64Sub = 0x7D
        case i64Mul = 0x7E
        case i64DivS = 0x7F
        case i64DivU = 0x80
        case i64RemS = 0x81
        case i64RemU = 0x82
        case i64And = 0x83
        case i64Or = 0x84
        case i64Xor = 0x85
        case i64Shl = 0x86
        case i64ShrS = 0x87
        case i64ShrU = 0x88
        case i64Rotl = 0x89
        case i64Rotr = 0x8A

        case i32Extend8S = 0xC0
        case i32Extend16S = 0xC1
        case i64Extend8S = 0xC2
        case i64Extend16S = 0xC3
        case i64Extend32S = 0xC4

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
        case .else: return .else
        case .br: return .br
        case .brIf: return .brIf
        case .brTable: return .brTable
        case .return: return .return
        case .call: return .call
        case .callIndirect: return .callIndirect
            
        // Parametric Instructions
        case .drop: return .drop
        case .select: return .select
            
        // Variable Instructions
        case .localGet: return .localGet
        case .localSet: return .localSet
        case .localTee: return .localTee
        case .globalGet: return .globalGet
        case .globalSet: return .globalSet
            
        case .f32Add: return .f32Add
        case .f64Add: return .f64Add
            
        // Memory Instructions
        case .i32Load: return .i32Load
        case .i32Store: return .i32Store
        case .dataDrop: return .dataDrop
            
        // Numeric Instructions
        case .i32Const: return .i32Const
        case .i64Const: return .i64Const
        case .f32Const: return .f32Const
        case .f64Const: return .f64Const
            
        case .i32Eqz: return .i32Eqz
        case .i32Eq: return .i32Eq
        case .i32Ne: return .i32Ne
        case .i32LtS: return .i32LtS
        case .i32LtU: return .i32LtU
        case .i32GtS: return .i32GtS
        case .i32GtU: return .i32GtU
        case .i32LeS: return .i32LeS
        case .i32LeU: return .i32LeU
        case .i32GeS: return .i32GeS
        case .i32GeU: return .i32GeU

        case .i64Eqz: return .i64Eqz
        case .i64Eq: return .i64Eq
        case .i64Ne: return .i64Ne
        case .i64LtS: return .i64LtS
        case .i64LtU: return .i64LtU
        case .i64GtS: return .i64GtS
        case .i64GtU: return .i64GtU
        case .i64LeS: return .i64LeS
        case .i64LeU: return .i64LeU
        case .i64GeS: return .i64GeS
        case .i64GeU: return .i64GeU

        case .i32Clz: return .i32Clz
        case .i32Ctz: return .i32Ctz
        case .i32Popcnt: return .i32Popcnt
        case .i32Add: return .i32Add
        case .i32Sub: return .i32Sub
        case .i32Mul: return .i32Mul
        case .i32DivS: return .i32DivS
        case .i32DivU: return .i32DivU
        case .i32RemS: return .i32RemS
        case .i32RemU: return .i32RemU
        case .i32And: return .i32And
        case .i32Or: return .i32Or
        case .i32Xor: return .i32Xor
        case .i32Shl: return .i32Shl
        case .i32ShrS: return .i32ShrS
        case .i32ShrU: return .i32ShrU
        case .i32Rotl: return .i32Rotl
        case .i32Rotr: return .i32Rotr
            
        case .i64Clz: return .i64Clz
        case .i64Ctz: return .i64Ctz
        case .i64Popcnt: return .i64Popcnt
        case .i64Add: return .i64Add
        case .i64Sub: return .i64Sub
        case .i64Mul: return .i64Mul
        case .i64DivS: return .i64DivS
        case .i64DivU: return .i64DivU
        case .i64RemS: return .i64RemS
        case .i64RemU: return .i64RemU
        case .i64And: return .i64And
        case .i64Or: return .i64Or
        case .i64Xor: return .i64Xor
        case .i64Shl: return .i64Shl
        case .i64ShrS: return .i64ShrS
        case .i64ShrU: return .i64ShrU
        case .i64Rotl: return .i64Rotl
        case .i64Rotr: return .i64Rotr

        case .i32Extend8S: return .i32Extend8S
        case .i32Extend16S: return .i32Extend16S
        case .i64Extend8S: return .i64Extend8S
        case .i64Extend16S: return .i64Extend16S
        case .i64Extend32S: return .i64Extend32S

        case .f32Div: return .f32Div
            
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
    
    var isElse: Bool {
        switch self {
        case .else: return true
        default: return false
        }
    }
    
    var isEnd: Bool {
        switch self {
        case .end: return true
        default: return false
        }
    }
}

// https://webassembly.github.io/spec/core/syntax/instructions.html#memory-instructions

struct MemoryArgument {
    let offset: U32
    let align: U32
}
