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
    func getFunctionType(at index: FunctionAddress) -> FunctionType {
        let instance = functions[index]
        return instance.functionType
    }
    
    func getGlobal(at index: GlobalAddress) -> Value {
        globals[index].value
    }
    
    func setGlobal(at index: GlobalAddress, value: Value) {
        globals[index].value = value
    }
}
