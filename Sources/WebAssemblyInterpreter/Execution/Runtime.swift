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
    private var store = Store()
    private var stack = Stack()
    
    public init() {
    }
}

public extension Runtime {
    func instanciate(module: Module) -> ModuleInstance {
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
        
        // Store
        let functionTypes: [FunctionType] = module.typeSection?.functionTypes.elements.map { $0 } ?? []
        let functionTypeIndices: [TypeIndex] = module.functionSection?.indices.elements.map { $0 } ?? []
        let codes = module.codeSection?.codes.elements ?? []
        let _functions = zip(functionTypeIndices, codes).map { funcTypeIndex, code in
            let functionType = functionTypes[Int(funcTypeIndex)]
            return Function(type: functionType,
                            index: funcTypeIndex,
                            locals: code.locals,
                            instructions: code.expression.instructions)
        }
        let functions: [FunctionAddress: FunctionInstance] = Dictionary(uniqueKeysWithValues: _functions.enumerated().map { index, function in
            (index, .init(functionType: function.type,
                                         code: .module(module: module,
                                                       code: function)))
        })

        // TODO: Support global.expression
        let globals: [GlobalAddress: GlobalInstance] = Dictionary(uniqueKeysWithValues: module.globalSection?.globals.elements.enumerated().map { index, global in
            (index, .init(type: global.type,
                                       value: .init(type: global.type.valueType)))
        } ?? [])
        
        store.merge(functions: functions,
                    globals: globals)
        
        return .init(exports: exportInstances)
    }
    
    // TODO: arguments should be ValueType
    func invoke(moduleInstance: ModuleInstance,
                functionName: String, arguments: [Value], result: inout Value?) throws {
        self.stack = .init()
        
        arguments.forEach { argument in
            stack.push(value: argument)
        }
        
        try executeFunction(moduleInstance: moduleInstance,
                            functionName: functionName)
        
        guard let resultValue = stack.pop(.number(.i32)) else {
            fatalError()
        }
        
        result = resultValue
    }
}

private extension Runtime {
    func executeFunction(moduleInstance: ModuleInstance,
                         functionName: String) throws {
        guard let export = moduleInstance.exports.first(where: { $0.name == functionName }) else {
            throw RuntimeError.exportedFunctionNotFound
        }
        
        guard case let .function(functionAddress) = export.value else {
            throw RuntimeError.exportedFunctionNotFound
        }
        
        call(moduleInstance: moduleInstance,
             functionIndex: functionAddress)
        
        var pc = 0
        while stack.currentFrame != nil {
            guard let instructions = stack.currentFrame?.function.instructions else { break }
            
            try executeInstruction(instructions: instructions, pc: &pc)
            pc += 1

            print("pc=\(pc)")
        }
    }

    func call(moduleInstance: ModuleInstance,
              functionIndex: FunctionAddress) {
        if functionIndex >= store.functions.count {
            fatalError()
        }
        
        let function = store.getFunction(index: functionIndex)
        var locals: [Value] = []
        function.type.resultType1.valueTypes.elements
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

        stack.push(frame: .init(module: moduleInstance,
                                function: function,
                                locals: locals))
    }
    
    func executeInstruction(instructions: [Instruction], pc: inout Int) throws {
        let instruction = instructions[pc]
        switch instruction {
        case .unreachable:
            fatalError()
        case .nop:
            fatalError()
        case let .block(blockType):
            guard let block = stack.currentFrame?.function.blocks[pc] else {
                fatalError()
            }
            
            pc = block.startIndex
             
            let label = Label(blockType: blockType, block: block)
            stack.push(label: label)
        case let .loop(blockType):
            guard let block = stack.currentFrame?.function.blocks[pc] else {
                fatalError()
            }
            
            pc = block.startIndex
             
            let label = Label(blockType: blockType, block: block)
            stack.push(label: label)
        case let .if(blockType):
            guard let value = stack.pop(.number(.i32)) else {
                fatalError("i32 values must be in the stack")
            }

            guard let block = stack.currentFrame?.function.blocks[pc] else {
                fatalError()
            }
            
            let ifValue: Bool
            switch value {
            case let .i32(value):
                ifValue = value == 0
            case let .i64(value):
                ifValue = value == 0
            case .vector:
                fatalError("Not implemented yet")
            }
            if ifValue {
                pc = block.endIndex! + 1
            } else {
                pc = block.startIndex
                
                guard let frame = stack.currentFrame else {
                    fatalError()
                }
                guard let block = frame.function.blocks[pc] else {
                    fatalError()
                }
                
                let label = Label(blockType: block.arity, block: block)
                stack.push(label: label)
            }
        case let .br(labelIndex):
            executeBr(labelIndex: labelIndex,
                      pc: &pc)
        case let .brIf(labelIndex):
            guard let value = stack.pop(.number(.i32)) else {
                fatalError("i32 values must be in the stack")
            }
            
            let ifValue: Bool
            switch value {
            case let .i32(value):
                ifValue = value != 0
            case let .i64(value):
                ifValue = value != 0
            case .vector:
                fatalError("Not implemented yet")
            }
            if ifValue {
                executeBr(labelIndex: labelIndex,
                          pc: &pc)
            }
        case .call:
            // TODO: Call imported function
            break
        case let .localGet(localIndex):
            let value = stack.currentFrame!.locals[Int(localIndex)]
            stack.push(value: value)
        case let .localSet(localIndex):
            let value = stack.currentFrame!.locals[Int(localIndex)]
            guard let poppedValue = stack.pop(value.type) else {
                throw RuntimeError.invalidValueType
            }
            stack.currentFrame!.locals[Int(localIndex)] = poppedValue
        case let .localTee(localIndex):
            guard let peekedValue = stack.peek() else {
                throw RuntimeError.invalidValueType
            }
            switch peekedValue {
            case .frame, .label:
                fatalError()
            case let .value(value):
                stack.currentFrame!.locals[Int(localIndex)] = value
            }
        case let .globalGet(globalIndex):
            // TODO: Should get global address from current frame
            let value = store.getGlobal(index: GlobalAddress(globalIndex))
            stack.push(value: value)
        case let .globalSet(globalIndex):
            // TODO: Should get global address from current frame
            guard let value = stack.popValue() else {
                throw RuntimeError.invalidValueType
            }
            store.setGlobal(index: GlobalAddress(globalIndex), value: value)
        case .f32Add:
            fatalError()
        case let .i32Const(value):
            stack.push(value: Value(value: value))
        case .i64Const:
            fatalError()
        case .f32Const:
            fatalError()
        case .f64Const:
            fatalError()
        case .i32Eq:
            fatalError()
        case .i32GeU:
            guard let c2Value = stack.pop(.number(.i32)),
                  let c1Value = stack.pop(.number(.i32)) else {
                throw RuntimeError.invalidValueType
            }
            guard case .i32(let value1) = c1Value,
                  case .i32(let value2) = c2Value else {
                throw RuntimeError.invalidValueType
            }
            
            let result: I32 = value1 >= value2 ? 1 : 0
            stack.push(value: Value(value: result))
        case .i32Add:
            guard let c2Value = stack.pop(.number(.i32)),
                  let c1Value = stack.pop(.number(.i32)) else {
                throw RuntimeError.invalidValueType
            }
            guard case .i32(let value1) = c1Value,
                  case .i32(let value2) = c2Value else {
                throw RuntimeError.invalidValueType
            }

            let result: I32 = value1 + value2
            stack.push(value: Value(value: result))
        case .i32Sub:
            fatalError()
        case .i32Mul:
            fatalError()
        case .end:
            if pc != (instructions.count - 1) {
                stack.popCurrentLabel()
                return
            }
            
            guard let resultType = stack.currentFrame?.function.type.resultType2.valueTypes.elements.first else {
                fatalError()
            }
            
            guard let resultValue = stack.pop(resultType) else {
                fatalError("Result value is not threre")
            }
            
            // Validation
            guard let currentElement = stack.peek() else {
                fatalError("Current element must be current frame")
            }
            switch currentElement {
            case let .frame(frame):
                if frame.id != stack.currentFrame?.id {
                    fatalError("Current element must be current frame")
                }
            case .label, .value:
                fatalError("Current element must be current frame")
            }
            
            stack.popCurrentFrame()
            stack.push(value: resultValue)
        }
    }
    
    func executeBr(labelIndex: LabelIndex, pc: inout Int) {
        let label = stack.label(index: labelIndex)
        var value: Value?
        if let valueType = label.arity {
            value = stack.pop(valueType)
        }
       
        stack.popAllFromLabel(index: labelIndex)
        if let value {
            stack.push(value: value)
        }
        
        if case .loop = label.block.instruction {
            pc = label.block.startIndex - 1
        } else {
            pc = label.block.endIndex!
        }
    }
}
