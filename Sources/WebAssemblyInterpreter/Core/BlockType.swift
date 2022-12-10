//
//  BlockType.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/10.
//

import Foundation

// https://webassembly.github.io/spec/core/binary/instructions.html#binary-blocktype
enum BlockType {
    case empty
    case value(ValueType)
    // TODO: Support type index
    //    case typeIndex
    
    var arity: Int {
        switch self {
        case .empty: return 0
        case .value: return 1
        }
    }
}
    
extension BlockType {
    static var emptyByte: Byte = 0x40
}
