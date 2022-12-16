//
//  HostEnvironment.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/17.
//

import Foundation

public class HostEnvironment {
    var codes: [String: HostCode] = [:]
    
    public init() {}
}

public extension HostEnvironment {
    func addCode(name: String, code: @escaping HostCode) {
        codes[name] = code
    }
}

extension HostEnvironment {
    func findCode(name: String) -> HostCode? {
        return codes[name]
    }
}
