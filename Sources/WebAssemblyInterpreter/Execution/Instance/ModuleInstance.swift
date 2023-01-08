//
//  ModuleInstance.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/31.
//

import Foundation

// https://webassembly.github.io/spec/core/exec/runtime.html#module-instances
public final class ModuleInstance {
    var types: [FunctionType] = []
    var functionAddresses: [FunctionAddress] = []
    var tableAddresses: [TableAddress] = []
    var memoryAddresses: [MemoryAddress] = []
    var globalAddresses: [GlobalAddress] = []
//    var elementAddresses: [ElementAddress] = []
//    var dataAddresses: [DataAddress] = []
    var exports: [ExportInstance] = []
}
