//
//  Store.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/03.
//

import Foundation

// https://www.slideshare.net/TakayaSaeki/webassemblyweb-244794176
public final class Store {
    private(set) var functions: [FunctionInstance] = []
    private(set) var tables: [TableInstance] = []
    private(set) var memories: [MemoryInstance] = []
    private(set) var globals: [GlobalInstance] = []
}

extension Store {
    // https://webassembly.github.io/spec/core/exec/modules.html#alloc-module
    func allocate(module: Module,
                  hostEnvironment: HostEnvironment) -> ModuleInstance {
        let moduleInstance = ModuleInstance()
        
        moduleInstance.types = module.types
        
        module.imports.forEach {
            allocate(import: $0,
                     module: moduleInstance,
                     hostEnvironment: hostEnvironment)
        }
        
        module.functions.forEach {
            allocate(function: $0, module: moduleInstance)
        }
        
        module.tables.forEach {
            allocate(tableType: $0, module: moduleInstance)
        }

        module.memories.forEach {
            allocate(memoryType: $0,
                     module: moduleInstance)
        }
        
        // TODO: Support global.expression
        module.globals.forEach { global in
            allocate(type: global.type,
                     value: .init(type: global.type.valueType),
                     module: moduleInstance)
        }

        moduleInstance.exports = module.exports.compactMap { export in
            switch export.descriptor {
            case let .function(functionIndex):
                return ExportInstance(name: export.name,
                                      value: .function(FunctionAddress(functionIndex)))
                
            case .table, .memory, .global:
                // TODO: Return instance with these types and replace compactMap with map
                return nil
            }
        }

        return moduleInstance
    }

    // https://webassembly.github.io/spec/core/exec/modules.html#alloc-func
    func allocate(function: Function, module: ModuleInstance) {
        let address = functions.count
        let functionType = module.types[Int(function.index)]
        let instance = FunctionInstance(functionType: functionType,
                                        code: .module(module: module, code: function))
        functions.append(instance)
        module.functionAddresses.append(address)
    }
    
    // https://webassembly.github.io/spec/core/exec/modules.html#alloc-table
    func allocate(tableType: TableType, module: ModuleInstance) {
        let address = tables.count
        let instance = TableInstance(type: tableType)
        tables.append(instance)
        module.tableAddresses.append(address)
    }
    
    // https://webassembly.github.io/spec/core/exec/modules.html#host-functions
    func allocate(import: ImportSection.Import,
                  module: ModuleInstance,
                  hostEnvironment: HostEnvironment) {
        switch `import`.descriptor {
        case let .function(typeIndex):
            let address = functions.count
            let functionType = module.types[Int(typeIndex)]
            guard let hostCode = hostEnvironment.findCode(name: `import`.name) else { fatalError() }
            let instance = FunctionInstance(functionType: functionType,
                                                    hostCode: hostCode)
            functions.append(instance)
            module.functionAddresses.append(address)
        case .table:
            fatalError("Not implemented yet")
        case let .memory(memoryType):
            allocate(memoryType: memoryType,
                     module: module)
        case let .global(globalType):
            let address = globals.count
            guard let globalValue = hostEnvironment.findGlobal(name: `import`.name),
                  globalValue.type == globalType.valueType else { fatalError("Imported global value is not matched") }
            let globalInstance = GlobalInstance(type: globalType,
                                                value: globalValue)
            globals.append(globalInstance)
            module.globalAddresses.append(address)
        }
    }

    // https://webassembly.github.io/spec/core/exec/modules.html#alloc-mem
    func allocate(memoryType: MemoryType,
                  module: ModuleInstance) {
        let address = memories.count
        let instance = MemoryInstance(type: memoryType)
        memories.append(instance)
        module.memoryAddresses.append(address)
    }

    // https://webassembly.github.io/spec/core/exec/modules.html#alloc-global
    func allocate(type: GlobalType,
                  value: Value,
                  module: ModuleInstance) {
        let address = globals.count
        let instance = GlobalInstance(type: type, value: value)
        globals.append(instance)
        module.globalAddresses.append(address)
    }
}

public extension Store {
    func write(memoryAddress: MemoryAddress,
               bytes: [Byte],
               offset: Int) {
        let memoryInstance = memories[memoryAddress]
        for index in 0..<bytes.count {
            memoryInstance.data[offset + index] = bytes[index]
        }
        let string = memoryInstance.data[0..<40].map { $0.hex }.joined()
        print("[Memory]\(string)")
    }
}

extension Store {
    func getGlobal(index: GlobalIndex) throws -> Value {
        guard globals.indices.contains(Int(index)) else {
            fatalError()
        }
        return globals[Int(index)].value
    }

    func setGlobal(index: GlobalIndex, value: Value) throws {
        guard globals.indices.contains(Int(index)) else {
            fatalError()
        }
        let global = globals[Int(index)]
        guard global.type.mutability == .var else {
            fatalError()
        }
        global.value = value
    }
}
