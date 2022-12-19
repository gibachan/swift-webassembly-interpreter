//
//  HostEnvironment.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/17.
//

import Foundation

public typealias HostCode = ([Value]) -> [Value]
public final class HostMemory {
    private let page: Int
    public var data: Data
    
    public init(page: Int) {
        self.page = page
        self.data = Data(count: page * 64 * 1000)
    }
    
    func initData() {
        data = Data(count: page * 64 * 1000)
    }
}

public final class HostEnvironment {
    private var codes: [String: HostCode] = [:]
    private var globals: [String: Value] = [:]
    public var memory: HostMemory = .init(page: 1)
    
    public init() {}
}

public extension HostEnvironment {
    func addCode(name: String, code: @escaping HostCode) {
        codes[name] = code
    }
    
    func addGlobal(name: String, value: Value) {
        globals[name] = value
    }
}

extension HostEnvironment {
    func initMemory(limits: Limits) {
        // TODO: Implement memory initilization
        memory.initData()
    }
    
    func updateMemory(data: DataSection.Data) {
        // TODO: Execute data.expression
        guard let position = data.expression.instructions.compactMap({ instruction in
            switch instruction {
            case let .globalGet(globalIndex):
                return Int(globalIndex)
            case let .i32Const(value):
                return Int(value)
            default:
                return nil
            }
        }).first else {
            return
        }
        
        let newData = memory.data.indices.map { index in
            if index >= position, index <= (position + data.initializer.elements.count - 1) {
                return data.initializer.elements[index - position]
            } else {
                return memory.data[index]
            }
        }
        
        self.memory.data = Data(newData)
    }
    
    func findCode(name: String) -> HostCode? {
        return codes[name]
    }
    
    func findGlobal(name: String) -> Value? {
        return globals[name]
    }
}
