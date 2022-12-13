//
//  Runtime.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/27.
//

import Foundation

enum RuntimeError: Error {
    case exportedFunctionNotFound
    case invalidValueType
}

public final class Runtime {
    private(set) var store = Store()
    private(set) var stack = Stack()
    
    public init() {
    }
}

public extension Runtime {
    // https://webassembly.github.io/spec/core/exec/modules.html#instantiation
    func instanciate(module: Module) -> ModuleInstance {
        // TODO: Validate the module
        
        // TODO: Validate provited imports match teh declared types
        
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
        
        let moduleInstance = ModuleInstance(exports: exportInstances)
        
        // Store
        let functionTypes: [FunctionType] = module.typeSection?.functionTypes.elements.map { $0 } ?? []
        let functionTypeIndices: [TypeIndex] = module.functionSection?.indices.elements.map { $0 } ?? []
        let codes = module.codeSection?.codes.elements ?? []
        let _functions = zip(functionTypeIndices, codes).map { funcTypeIndex, code in
            let functionType = functionTypes[Int(funcTypeIndex)]
            return Function(type: functionType,
                            index: funcTypeIndex,
                            locals: code.locals,
                            body: code.expression)
        }
        let functions: [FunctionInstance] = _functions.map { function in
                .init(functionType: function.type,
                      code: .module(module: moduleInstance,
                                    code: function))
        }
        
        // TODO: Support global.expression
        let globals: [GlobalInstance] = module.globalSection?.globals.elements.map { global in
                .init(type: global.type,
                      value: .init(type: global.type.valueType))
        } ?? []
        self.store = Store(functions: functions,
                           globals: globals)
        
        // TODO: Execute start function?
        
        return moduleInstance
    }
    
    func invoke(moduleInstance: ModuleInstance,
                functionName: String, arguments: [Value], result: inout Value?) throws {
        self.stack = .init()

        arguments.forEach { argument in
            stack.push(value: argument)
        }
        
        guard let export = moduleInstance.exports.first(where: { $0.name == functionName }) else {
            throw RuntimeError.exportedFunctionNotFound
        }
        
        guard case let .function(functionAddress) = export.value else {
            throw RuntimeError.exportedFunctionNotFound
        }
        
        if functionAddress >= store.functions.count {
            fatalError()
        }
        
        let function = store.getFunction(at: functionAddress)
        
        try executeFunction(moduleInstance: moduleInstance,
                            functionAddress: functionAddress)
        
        // Currently, we support only one result value
        if let resultType = function.type.resultTypes.valueTypes.elements.first {
            result = stack.pop(resultType)
        } else {
            result = .i32(0)
        }
    }
}

extension Runtime {
    func executeFunction(moduleInstance: ModuleInstance,
                         functionAddress: FunctionAddress) throws {
        
        stackActivationFrame(at: functionAddress,
                             in: moduleInstance)
        
        while stack.currentFrame != nil {
            let frame = stack.currentFrame!
            try execute(frame: frame)
            frame.pc += 1
        }
    }

    func stackActivationFrame(at address: FunctionAddress,
                      in module: ModuleInstance) {
        if address >= store.functions.count {
            fatalError()
        }
        
        let function = store.getFunction(at: address)
        var locals: [Value] = []
        function.type.parameterTypes.valueTypes.elements
            .reversed()
            .forEach { valueType in
                guard let value = stack.pop(valueType) else {
                    // TODO: throw exception
                    fatalError()
                }
                switch value {
                case let .i32(value):
                    locals.insert(Value(value: value), at: 0)
                case let .i64(value):
                    locals.insert(Value(value: value), at: 0)
                case .vector:
                    fatalError("Not implemented yet")
                }
            }
        function.locals.forEach { valueType in
            locals.append(Value(type: valueType))
        }

        stack.push(frame: .init(module: module,
                                function: function,
                                locals: locals))
    }
}
