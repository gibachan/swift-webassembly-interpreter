//
//  Instances.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/04.
//

import Foundation

// https://webassembly.github.io/spec/core/exec/runtime.html#module-instances
public final class ModuleInstance {
    let exports: [ExportInstance]
    
    init(exports: [ExportInstance]) {
        self.exports = exports
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#function-instances
public final class FunctionInstance {
    let functionType: FunctionType
    let code: Code
    
    init(functionType: FunctionType, code: Code) {
        self.functionType = functionType
        self.code = code
    }
    
    enum Code {
        case module(module: Module, code: Function)
//        case host(hostCode: HostFunction)
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#global-instances
public final class GlobalInstance {
    let type: GlobalType
    var value: Value
    
    init(type: GlobalType, value: Value) {
        self.type = type
        self.value = value
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#export-instances
public final class ExportInstance {
    let name: String
    let value: ExternalValue
    
    init(name: String, value: ExternalValue) {
        self.name = name
        self.value = value
    }
}


// https://webassembly.github.io/spec/core/exec/runtime.html#external-values
public enum ExternalValue {
    case function(FunctionAddress)
    case table(TableAddress)
    case memory(MemoryAddress)
    case global(GlobalAddress)
}
