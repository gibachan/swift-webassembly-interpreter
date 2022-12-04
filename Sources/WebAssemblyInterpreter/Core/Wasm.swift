//
//  Wasm.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/10.
//

import Foundation

public struct Wasm {
    public let module: Module
    
    public init(
        module: Module
    ) {
        self.module = module
    }
}
