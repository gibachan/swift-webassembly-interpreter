//
//  Expression.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/10.
//

import Foundation

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
