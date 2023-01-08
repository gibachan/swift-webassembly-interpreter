//
//  Instances.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/04.
//

import Foundation

// https://webassembly.github.io/spec/core/exec/runtime.html#function-instances
public final class FunctionInstance {
    let functionType: FunctionType
    let code: Code
    
    init(functionType: FunctionType,
         code: Code) {
        self.functionType = functionType
        self.code = code
    }

    init(functionType: FunctionType,
         hostCode: @escaping HostCode) {
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
public final class TableInstance {
    let type: TableType
    var elements: [Reference]
    
    init(type: TableType) {
        self.type = type
        let elementCount = type.limits.max ?? type.limits.min
        self.elements = Array(repeating: .null, count: Int(elementCount))
    }
}

// https://webassembly.github.io/spec/core/exec/runtime.html#memory-instances
public final class MemoryInstance {
    private static let pageSize = 65536

    let type: MemoryType
    var data: [Byte]

    init(type: MemoryType) {
        self.type = type
        self.data = Array(repeating: 0, count: Int(type.min) * MemoryInstance.pageSize)
    }
}

extension MemoryInstance {
    var max: U32? { type.max }
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
