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
        
        // TODO: Validate the module
        
        // TODO: Validate provited imports match teh declared types
        
        let moduleInstance = ModuleInstance.instantiate(module: module)
        
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
        var functions: [FunctionInstance] = []
        var globals: [GlobalInstance] = []
        
        module.importSection?.imports.elements.forEach { _import in
            switch _import.descriptor {
            case let .function(typeIndex):
                let functionType = functionTypes[Int(typeIndex)]
                // TODO: Consider which module the code should be imported
                guard let hostCode = hostEnvironment.findCode(name: _import.name) else { fatalError() }
                let functionInstance = FunctionInstance(functionType: functionType,
                                                        hostCode: hostCode)
                functions.append(functionInstance)
            case .table:
                // TODO: Implement with tableType
                break
            case let .memory(memoryType):
                hostEnvironment.initMemory(limits: memoryType)
            case let .global(globalType):
                guard let globalValue = hostEnvironment.findGlobal(name: _import.name),
                      globalValue.type == globalType.valueType else { fatalError("Imported global value is not matched") }
                let globalInstance = GlobalInstance(type: globalType,
                                                    value: globalValue)
                globals.append(globalInstance)
            }
        }
        
        _functions.forEach { function in
            let functionInstance = FunctionInstance(functionType: function.type,
                                                    code: .module(module: moduleInstance,
                                                                  code: function))
            functions.append(functionInstance)
        }

        // TODO: Support global.expression
        module.globalSection?.globals.elements.forEach { global in
            let globalInstance = GlobalInstance(type: global.type,
                                                value: .init(type: global.type.valueType))
            globals.append(globalInstance)
        }

        self.store = Store(functions: functions,
                           globals: globals)
        
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

            stack.push(frame: .init(module: module,
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
