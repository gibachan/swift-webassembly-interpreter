//
//  Runtime+Execution.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/13.
//

import Foundation

extension Runtime {
    func execute(frame: Frame) throws {
        let instruction = frame.currentInstruction
        
//        print("Executing... \(instruction)")

        switch instruction {
        case .unreachable:
            fatalError()
        case .nop:
            fatalError()
        case let .block(blockType):
            let endIndex = frame.function.body.findEndIndex(from: frame.pc)
            let label = Label(blockType: blockType,
                              startIndex: frame.pc,
                              endIndex: endIndex,
                              isLoop: false)
            stack.push(label: label)
            // endIndex = 29 => 36
        case let .loop(blockType):
            let endIndex = frame.function.body.findEndIndex(from: frame.pc)
            let label = Label(blockType: blockType,
                              startIndex: frame.pc,
                              endIndex: endIndex,
                              isLoop: true)
            stack.push(label: label)
        case let .if(blockType):
            guard let value = stack.pop(.number(.i32)) else {
                fatalError("i32 values must be in the stack")
            }

            let elseIndex = frame.function.body.findElseIndex(from: frame.pc)
            let endIndex = frame.function.body.findEndIndex(from: frame.pc)

            let ifValue: Bool
            switch value {
            case let .i32(value):
                ifValue = value != 0
            case let .i64(value):
                ifValue = value != 0
            case let .f32(value):
                ifValue = value != 0
            case let .f64(value):
                ifValue = value != 0
            case .vector:
                fatalError("Not implemented yet")
            }
            if ifValue {
                let label = Label(blockType: blockType,
                                  startIndex: frame.pc,
                                  endIndex: endIndex,
                                  isLoop: false)
                stack.push(label: label)
            } else {
                if let elseIndex {
                    frame.pc = elseIndex
                    let label = Label(blockType: blockType,
                                      startIndex: elseIndex,
                                      endIndex: endIndex,
                                      isLoop: false)
                    stack.push(label: label)
                } else {
                    frame.pc = endIndex //+ 1
                }
            }
        case .else:
            guard let label = stack.currentLabel else {
                fatalError()
            }
            stack.popCurrentLabel()
            frame.pc = label.endIndex!
        case let .br(labelIndex):
            executeBr(labelIndex: labelIndex,
                      pc: &frame.pc)
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
            case let .f32(value):
                ifValue = value != 0
            case let .f64(value):
                ifValue = value != 0
            case .vector:
                fatalError("Not implemented yet")
            }
            if ifValue {
                executeBr(labelIndex: labelIndex,
                          pc: &frame.pc)
            }
        case .return:
            // .number(.i32) must be an arity of current frame
            guard let value = stack.pop(.number(.i32)) else {
                fatalError("i32 values must be in the stack")
            }
            
            stack.popCurrentFrame()
            stack.push(value: value)
        case let .call(functionIndex):
            guard let frame = stack.currentFrame else {
                fatalError()
            }
            stackActivationFrame(at: FunctionAddress(functionIndex),
                                 in: frame.module)
        case .callIndirect:
            fatalError()

        case let .localGet(localIndex):
            let value = frame.locals[Int(localIndex)]
            stack.push(value: value)
        case let .localSet(localIndex):
            let value = stack.currentFrame!.locals[Int(localIndex)]
            guard let poppedValue = stack.pop(value.type) else {
                throw RuntimeError.invalidValueType
            }
            frame.locals[Int(localIndex)] = poppedValue
        case let .localTee(localIndex):
            guard let peekedValue = stack.peek() else {
                throw RuntimeError.invalidValueType
            }
            switch peekedValue {
            case .activation, .label:
                fatalError()
            case let .value(value):
                frame.locals[Int(localIndex)] = value
            }
        case let .globalGet(globalIndex):
            // TODO: Should get global address from current frame
            let value = try store.getGlobal(index: globalIndex)
            stack.push(value: value)
        case let .globalSet(globalIndex):
            // TODO: Should get global address from current frame
            guard let value = stack.popValue() else {
                throw RuntimeError.invalidValueType
            }
            try store.setGlobal(index: globalIndex, value: value)
        case .f32Add:
            guard let c2Value = stack.pop(.number(.f32)),
                  let c1Value = stack.pop(.number(.f32)) else {
                throw RuntimeError.invalidValueType
            }
            guard case .f32(let value1) = c1Value,
                  case .f32(let value2) = c2Value else {
                throw RuntimeError.invalidValueType
            }

            let result: F32 = value1 + value2
            stack.push(value: Value(value: result))
        case .f64Add:
            guard let c2Value = stack.pop(.number(.f64)),
                  let c1Value = stack.pop(.number(.f64)) else {
                throw RuntimeError.invalidValueType
            }
            guard case .f64(let value1) = c1Value,
                  case .f64(let value2) = c2Value else {
                throw RuntimeError.invalidValueType
            }

            let result: F64 = value1 + value2
            stack.push(value: Value(value: result))
            
        // Memory Instructions
        case .i32Load:
            fatalError()
        case .dataDrop:
            fatalError()
            
        // Numeric Instructions
        case let .i32Const(value):
            stack.push(value: Value(value: value))
        case .i64Const:
            fatalError()
        case .f32Const:
            fatalError()
        case .f64Const:
            fatalError()
        case .i32Eq:
            // https://webassembly.github.io/spec/core/exec/numerics.html#xref-exec-numerics-op-ieq-mathrm-ieq-n-i-1-i-2
            guard let c2Value = stack.pop(.number(.i32)),
                  let c1Value = stack.pop(.number(.i32)) else {
                throw RuntimeError.invalidValueType
            }
            guard case .i32(let value1) = c1Value,
                  case .i32(let value2) = c2Value else {
                throw RuntimeError.invalidValueType
            }
            
            let result: I32 = value1 == value2 ? 1 : 0
            stack.push(value: Value(value: result))
        case .i32LeU:
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
        case .i32RemU:
            guard let c2Value = stack.pop(.number(.i32)),
                  let c1Value = stack.pop(.number(.i32)) else {
                throw RuntimeError.invalidValueType
            }
            guard case .i32(let value1) = c1Value,
                  case .i32(let value2) = c2Value else {
                throw RuntimeError.invalidValueType
            }
            
            let result: I32 = value1 % value2
            stack.push(value: Value(value: result))
        case .i64Add:
            guard let c2Value = stack.pop(.number(.i64)),
                  let c1Value = stack.pop(.number(.i64)) else {
                throw RuntimeError.invalidValueType
            }
            guard case .i64(let value1) = c1Value,
                  case .i64(let value2) = c2Value else {
                throw RuntimeError.invalidValueType
            }

            let result: I64 = value1 + value2
            stack.push(value: Value(value: result))
        case .end:
            if !frame.isReachedEnd {
                stack.popCurrentLabel()
                return
            }
            
            if frame.arity == 0 {
                // No return value
                stack.popCurrentFrame()
                return
            }
            
            var resultValues: [Value] = []
            for _ in 0..<frame.arity {
                guard let value = stack.popValue() else { fatalError("Value should be popped from the stack") }
                resultValues.append(value)
            }
            
            // Validation
            guard let currentElement = stack.peek() else {
                fatalError("Current element must be current frame")
            }
            switch currentElement {
            case let .activation(frame):
                if frame.id != stack.currentFrame?.id {
                    fatalError("Current element must be current frame")
                }
                
                stack.popCurrentFrame()
                resultValues.forEach {
                    stack.push(value: $0)
                }
            case .label, .value:
                fatalError("Current element must be current frame")
            }
        }
    }
    
    func executeBr(labelIndex: LabelIndex, pc: inout Int) {
        let label = stack.label(index: labelIndex)
        var values: [Value] = []
        
        for _ in 0..<label.arity {
            guard let value = stack.popValue() else {
                fatalError()
            }
            // TODO: Check if the ordering is correct
            values.append(value)
        }
       
        stack.popAllFromLabel(index: labelIndex)
        
        values.forEach {
            stack.push(value: $0)
        }
        
        if label.isLoop {
            pc = label.startIndex - 1
        } else {
            pc = label.endIndex!
        }
    }
}
