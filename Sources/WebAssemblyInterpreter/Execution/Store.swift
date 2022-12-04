//
//  Store.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/03.
//

import Foundation



final class Store {
    private(set) var functions: [FunctionAddress: FunctionInstance]
    private(set) var globals: [GlobalAddress: GlobalInstance]
    
    init(functions: [FunctionAddress: FunctionInstance] = [:],
         globals: [GlobalAddress: GlobalInstance] = [:]) {
        self.functions = functions
        self.globals = globals
    }
}

extension Store {
    func merge(functions: [FunctionAddress: FunctionInstance] = [:],
               globals: [GlobalAddress: GlobalInstance] = [:]) {
        functions.forEach {
            self.functions[$0.key] = $0.value
        }
        globals.forEach {
            self.globals[$0.key] = $0.value
        }
    }

    func getFunction(index: FunctionAddress) -> Function {
        let instance = functions[index]!
        switch instance.code {
        case let .module(module: _, code: function):
            return function
        }
    }
    
    func getGlobal(index: GlobalAddress) -> Value {
        globals[index]!.value
    }
    
    func setGlobal(index: GlobalAddress, value: Value) {
        globals[index]!.value = value
    }
}
