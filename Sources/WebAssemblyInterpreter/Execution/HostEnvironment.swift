//
//  HostEnvironment.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/17.
//

import Foundation

public typealias HostCode = ([Value]) -> [Value]
public final class HostMemory {
    public var data: String
    
    public init() {
        data = ""
    }
}

public final class HostEnvironment {
    private var codes: [String: HostCode] = [:]
    private var globals: [String: Value] = [:]
    public var memory: HostMemory = .init()
    
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
        memory.data = ""
    }
    
    func findCode(name: String) -> HostCode? {
        return codes[name]
    }
    
    func findGlobal(name: String) -> Value? {
        return globals[name]
    }
}
