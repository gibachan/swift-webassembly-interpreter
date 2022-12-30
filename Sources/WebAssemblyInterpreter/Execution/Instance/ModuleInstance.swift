//
//  ModuleInstance.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/31.
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

extension ModuleInstance {
    static func instantiate(module: Module) -> ModuleInstance {
        let exports = module.exportSection?.exports.elements ?? []
        let exportInstances = exports.compactMap { export in
            switch export.descriptor {
            case let .function(functionIndex):
                return ExportInstance(name: export.name,
                                      value: .function(FunctionAddress(functionIndex)))
                
            case .table, .memory, .global:
                // TODO: Return instance with these types and replace compactMap with map
                return nil
            }
        }
        
        return .init(exports: exportInstances)
    }
}
