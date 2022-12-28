//
//  Instances.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/04.
//

import Foundation

// https://webassembly.github.io/spec/core/exec/runtime.html#module-instances
public final class ModuleInstance {
//    let types: [FunctionType]
//    let functionAddresses: [FunctionAddress]
//    let tableAddresses: [TableAddress]
//    let memoryAddresses: [MemoryAddress]
//    let globalAddresses: [GlobalAddress]
//    let elementAddresses: [ElementAddress]
//    let dataAddresses: [DataAddress]
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

    init(functionType: FunctionType, hostCode: @escaping HostCode) {
        self.functionType = functionType
        self.code = .host(hostCode: hostCode)
    }

    enum Code {
        case module(module: ModuleInstance, code: Function)
        // A host function is a function expressed outside WebAssembly but passed to a module as an import.
        case host(hostCode: HostCode)
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#table-instances
public final class TableInstance {} // TODO: implement

// https://webassembly.github.io/spec/core/exec/runtime.html#memory-instances
public final class MemoryInstance {} // TODO: implement

// https://webassembly.github.io/spec/core/exec/runtime.html#global-instances
public final class GlobalInstance {
    let type: GlobalType
    var value: Value
    
    init(type: GlobalType, value: Value) {
        self.type = type
        self.value = value
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#element-instances
public final class ElementInstance {} // TODO: implement

// https://webassembly.github.io/spec/core/exec/runtime.html#data-instances
public final class DataInstance {} // TODO: implement

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
public enum ExternalValue: Equatable {
    case function(FunctionAddress)
    case table(TableAddress)
    case memory(MemoryAddress)
    case global(GlobalAddress)
}
