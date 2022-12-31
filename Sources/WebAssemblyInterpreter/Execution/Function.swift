//
//  Function.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import Foundation

// https://webassembly.github.io/spec/core/syntax/modules.html#functions
struct Function {
    let index: TypeIndex
    let locals: [ValueType]
    let body: Expression
}

extension Expression {
    func findElseIndex(from startIndex: Int) -> Int? {
        var counter = 0
        for i in (startIndex..<instructions.endIndex) {
            let instruction = instructions[i]
            if instruction.isBlock {
                counter += 1
            } else if instruction.isEnd {
                counter -= 1
            } else if instruction.isElse, counter == 1 {
                return i
            }
            if counter == 0 {
                return nil
            }
        }
        fatalError()
    }

    func findEndIndex(from startIndex: Int) -> Int {
        var counter = 0
        for i in (startIndex..<instructions.endIndex) {
            let instruction = instructions[i]
            if instruction.isBlock {
                counter += 1
            } else if instruction.isEnd {
                counter -= 1
            }
            if counter == 0 {
                return i
            }
        }
        fatalError()
    }
}
