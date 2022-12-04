//
//  Stack.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/27.
//

import Foundation

// https://webassembly.github.io/spec/core/exec/runtime.html#stack

enum StackElement {
    case frame(Frame)
    case label(Label)
    case value(Value)
}

final class Stack {
    private var elements: [StackElement] = []
    private var labelPositions: [Int] = []
    
    var currentFrame: Frame? {
        let element = elements.last { element in
            switch element {
            case .frame: return true
            case .value, .label: return false
            }
        }
        if case let .frame(frame) = element {
            return frame
        } else {
            return nil
        }
    }
    
    var currentLabel: Label? {
        let element = elements.last { _element in
            switch _element {
            case .label: return true
            case .value, .frame: return false
            }
        }
        if case .label(let label) = element {
            return label
        }
        return nil
    }
    
    func popCurrentFrame() {
        guard let frameIndex = elements.lastIndex(where: { element in
            switch element {
            case .frame:
                return true
            case .value, .label:
                return false
            }
        }) else {
            fatalError()
        }
        
        elements = Array(elements[elements.startIndex..<frameIndex])
    }

    func popCurrentLabel() {
        guard let labelIndex = elements.lastIndex(where: { element in
            switch element {
            case .label:
                return true
            case .value, .frame:
                return false
            }
        }) else {
            fatalError()
        }
        
        elements = Array(elements[elements.startIndex..<labelIndex])
    }
    
    func push(value: Value) {
        elements.append(.value(value))
    }
    
    func push(frame: Frame) {
        elements.append(.frame(frame))
    }
    
    func push(label: Label) {
        elements.append(.label(label))
        labelPositions.append(elements.count - 1)
    }
    
    func pop(_ valueType: ValueType) -> Value? {
        if case .value(let value) = elements.last {
            if value.type == valueType {
                _ = elements.popLast()
                return value
            }
        }
        return nil
    }
    
    func popValue() -> Value? {
        if case .value(let value) = elements.last {
            _ = elements.popLast()
            return value
        }
        return nil
    }
    
    func peek() -> StackElement? {
        elements.last
    }
    
    func popAllFromLabel(index: LabelIndex) {
        var targetIndex = 0
        var labelCounter = 0
        elements
            .enumerated()
            .reversed()
            .forEach { currentIndex, element in
                switch element {
                case .label:
                    if labelCounter == index {
                        targetIndex = currentIndex
                    }
                    labelCounter += 1
                case .frame, .value:
                    break
                }
            }
        elements = Array(elements[elements.startIndex..<targetIndex])
    }
    
    func label(index: LabelIndex) -> Label {
        var targetIndex = 0
        var labelCounter = 0
        elements
            .enumerated()
            .reversed()
            .forEach { currentIndex, element in
                switch element {
                case .label:
                    if labelCounter == index {
                        targetIndex = currentIndex
                    }
                    labelCounter += 1
                case .frame, .value:
                    break
                }
            }
        let element = elements[targetIndex]
        switch element {
        case .frame, .value:
            fatalError()
        case let .label(label):
            return label
        }
    }
}

extension Stack: CustomDebugStringConvertible {
    public var debugDescription: String {
        [
            "[Stack] element count: \(elements.count)",
            elements.map { "- \($0)" }
                .joined(separator: "\n")
        ].joined(separator: "\n")
    }
}
