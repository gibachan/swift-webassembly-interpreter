//
//  Frame.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import Foundation

final class Frame {
    let id = UUID().uuidString
    let module: ModuleInstance
    let function: Function
    var locals: [Value]
    
    init(module: ModuleInstance,
         function: Function,
         locals: [Value]) {
        self.module = module
        self.function = function
        self.locals = locals
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
