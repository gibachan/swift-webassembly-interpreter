//
//  RuntimeTests.swift
//
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

@testable import WebAssemblyInterpreter
import XCTest

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
        XCTAssertEqual(result, .i32(6_765))

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "fib", arguments: [.i32(30)], result: &result)
        XCTAssertEqual(result, .i32(832_040))
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
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddInt", arguments: [.i32(2147483646), .i32(1)], result: &result)
        XCTAssertEqual(result, .i32(2147483647))

        // Overflow
//        try runtime.invoke(moduleInstance: moduleInstance,
//                           functionName: "AddInt", arguments: [.i32(2147483646), .i32(2)], result: &result)
//        XCTAssertEqual(result, .i32(-2147483648))
    }

    func testAddIntI64() throws {
        let fileURL = Bundle.module.url(forResource: "func_add_int_i64", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddInt", arguments: [.i64(100), .i64(23)], result: &result)
        XCTAssertEqual(result, .i64(123))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddInt", arguments: [.i64(9223372036854775806), .i64(1)], result: &result)
        XCTAssertEqual(result, .i64(9223372036854775807))

        // Overflow
//        try runtime.invoke(moduleInstance: moduleInstance,
//                           functionName: "AddInt", arguments: [.i64(9223372036854775806), .i64(2)], result: &result)
//        XCTAssertEqual(result, .i64(-9223372036854775808))
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

    func testIsPrime() throws {
        let fileURL = Bundle.module.url(forResource: "is_prime", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "is_prime", arguments: [.i32(1)], result: &result)
        XCTAssertEqual(result, .i32(0))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "is_prime", arguments: [.i32(2)], result: &result)
        XCTAssertEqual(result, .i32(1))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "is_prime", arguments: [.i32(97)], result: &result)
        XCTAssertEqual(result, .i32(1))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "is_prime", arguments: [.i32(98)], result: &result)
        XCTAssertEqual(result, .i32(0))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "is_prime", arguments: [.i32(997)], result: &result)
        XCTAssertEqual(result, .i32(1))
    }

    func testImportFunction() throws {
        let fileURL = Bundle.module.url(forResource: "import_function", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let hostEnvironment = HostEnvironment()
        hostEnvironment.addCode(name: "increment") { arguments in
            guard let argument = arguments.first else { fatalError() }
            if case let .i32(value) = argument {
                return [.i32(value + 1)]
            } else {
                fatalError()
            }
        }
        hostEnvironment.addCode(name: "decrement") { arguments in
            guard let argument = arguments.first else { fatalError() }
            if case let .i32(value) = argument {
                return [.i32(value - 1)]
            } else {
                fatalError()
            }
        }
        let moduleInstance = runtime.instanciate(module: wasm.module, hostEnvironment: hostEnvironment)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "CallImportedFunction", arguments: [], result: &result)
        XCTAssertEqual(result, .i32(10))
    }

    func testHelloWorld() throws {
        let fileURL = Bundle.module.url(forResource: "helloworld", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let hostEnvironment = HostEnvironment()
        var printStringCalled = false
        hostEnvironment.addCode(name: "print_string") { _ in
            printStringCalled = true
            XCTAssertEqual(hostEnvironment.memory.data, "hello world!")
            return []
        }
        hostEnvironment.addGlobal(name: "start_string", value: .i32(0))
        let moduleInstance = runtime.instanciate(module: wasm.module, hostEnvironment: hostEnvironment)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "helloworld", arguments: [], result: &result)
        XCTAssertTrue(printStringCalled)
    }
}
