//
//  RuntimeTests.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import XCTest
@testable import WebAssemblyInterpreter

final class RuntimeTests: XCTestCase {
    func testFibonacciSequence() throws {
        let fileURL = Bundle.module.url(forResource: "fib", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "fib", arguments: [.i32(10)], result: &result)
        XCTAssertEqual(result, .i32(55))

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "fib", arguments: [.i32(20)], result: &result)
        XCTAssertEqual(result, .i32(6765))

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "fib", arguments: [.i32(30)], result: &result)
        XCTAssertEqual(result, .i32(832040))
    }
    
    func testAddInt() throws {
        let fileURL = Bundle.module.url(forResource: "func_add_int", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddInt", arguments: [.i32(100), .i32(23)], result: &result)
        XCTAssertEqual(result, .i32(123))
    }
    
    func testMutableGlobal() throws {
        let fileURL = Bundle.module.url(forResource: "mutable_global", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "increment_global", arguments: [], result: &result)
        XCTAssertEqual(result, .i32(1))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "increment_global", arguments: [], result: &result)
        XCTAssertEqual(result, .i32(2))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "increment_global", arguments: [], result: &result)
        XCTAssertEqual(result, .i32(3))
    }
}
