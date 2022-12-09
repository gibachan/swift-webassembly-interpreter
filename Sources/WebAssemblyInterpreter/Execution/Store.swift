//
//  Store.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/03.
//

import Foundation

// https://www.slideshare.net/TakayaSaeki/webassemblyweb-244794176
final class Store {
    private(set) var functions: [FunctionInstance]
    private(set) var globals: [GlobalInstance]
    
    init(functions: [FunctionInstance] = [],
         globals: [GlobalInstance] = []) {
        self.functions = functions
        self.globals = globals
    }
}

extension Store {
    func getFunction(at index: FunctionAddress) -> Function {
        let instance = functions[index]
        switch instance.code {
        case let .module(module: _, code: function):
            return function
        }
    }
    
    func getGlobal(at index: GlobalAddress) -> Value {
        globals[index].value
    }
    
    func setGlobal(at index: GlobalAddress, value: Value) {
        globals[index].value = value
    }
}
