//
//  Frame.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import Foundation

// https://webassembly.github.io/spec/core/exec/runtime.html#activations-and-frames
final class Frame {
    let id = UUID().uuidString // for debug purpose
    let arity: Int
    let module: ModuleInstance
    let function: Function
    var locals: [Value]
    var pc: Int = 0
    
    init(arity: Int,
         module: ModuleInstance,
         function: Function,
         locals: [Value]) {
        self.arity = arity
        self.module = module
        self.function = function
        self.locals = locals
    }
}

extension Frame {
    var currentInstruction: Instruction {
        function.body.instructions[pc]
    }
    
    var isReachedEnd: Bool {
        pc == (function.body.instructions.count - 1)
    }
}

extension Frame: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Frame] ID: \(id)",
            "local count: \(locals.count)",
            locals
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

extension Frame {
    func findLocal(index: LocalIndex) -> Value {
        return locals[Int(index)]
    }
}
