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
    func instanciate(module: Module,
                     hostEnvironment: HostEnvironment = .init()) -> ModuleInstance {
        
        let moduleInstance = store.allocate(module: module,
                                            hostEnvironment: hostEnvironment)
        
        initMemory(module: module, hostEnvironment: hostEnvironment)
        
        // TODO: Execute start function?
        
        return moduleInstance
    }
    
    func invoke(moduleInstance: ModuleInstance,
                functionName: String,
                arguments: [Value],
                result: inout Value?) throws {
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
        
        let functionType = store.getFunctionType(at: functionAddress)
        
        try executeFunction(moduleInstance: moduleInstance,
                            functionAddress: functionAddress)
        
        // Currently, we support only one result value
        if let resultType = functionType.resultTypes.valueTypes.elements.first {
            result = stack.pop(resultType)
        } else {
            result = .i32(0)
        }
    }
}

extension Runtime {
    func initMemory(module: Module, hostEnvironment: HostEnvironment) {
        guard let dataSection = module.dataSection else { return }
        dataSection.datas.elements.forEach { data in
            hostEnvironment.updateMemory(data: data)
        }
    }
    
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
        
        let functionInstance = store.functions[address]
        let functionType = functionInstance.functionType
        switch functionInstance.code {
        case let .module(module, code):
            let function: Function = code
            var locals: [Value] = []
            functionType.parameterTypes.valueTypes.elements
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
                    case let .f32(value):
                        locals.insert(Value(value: value), at: 0)
                    case let .f64(value):
                        locals.insert(Value(value: value), at: 0)
                    case .vector:
                        fatalError("Not implemented yet")
                    }
                }
            function.locals.forEach { valueType in
                locals.append(Value(type: valueType))
            }

            stack.push(frame: .init(arity: functionType.resultTypes.valueTypes.elements.count,
                                    module: module,
                                    function: function,
                                    locals: locals))
        case let .host(hostCode: hostCode):
            let arguments = functionType.parameterTypes.valueTypes.elements
                .reversed()
                .map { valueType in
                    guard let value = stack.pop(valueType) else {
                        // TODO: throw exception
                        fatalError()
                    }
                    return value
                }
            let results = hostCode(arguments)
            results.forEach { stack.push(value: $0) }
        }
    }
}
