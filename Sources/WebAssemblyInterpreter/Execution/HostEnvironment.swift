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
        self.data = Data() // FIXME
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
    func findCode(name: String) -> HostCode? {
        return codes[name]
    }
    
    func findGlobal(name: String) -> Value? {
        return globals[name]
    }
}
