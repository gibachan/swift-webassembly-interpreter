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

    func testAddFloat() throws {
        let fileURL = Bundle.module.url(forResource: "func_add_float", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddFloat", arguments: [.f32(1.5), .f32(2.4)], result: &result)
        XCTAssertEqual(result, .f32(3.9))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddFloat", arguments: [.f32(Float.greatestFiniteMagnitude - 0.1), .f32(0.1)], result: &result)
        XCTAssertEqual(result, .f32(Float.greatestFiniteMagnitude))
    }

    func testAddFloat64() throws {
        let fileURL = Bundle.module.url(forResource: "func_add_float_f64", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddFloat64", arguments: [.f64(1.5), .f64(2.4)], result: &result)
        XCTAssertEqual(result, .f64(3.9))
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "AddFloat64", arguments: [.f64(Double.greatestFiniteMagnitude - 0.1), .f64(0.1)], result: &result)
        XCTAssertEqual(result, .f64(Double.greatestFiniteMagnitude))
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
        hostEnvironment.addCode(name: "print_string") { arguments in
            guard arguments.count == 1 else {
                XCTFail()
                return []
            }
            let argument = arguments[0]
            switch argument {
            case .i32:
                XCTAssertEqual(hostEnvironment.memory.data.prefix("hello world!".count), "hello world!".data(using: .utf8))
            default:
                XCTFail()
            }
            printStringCalled = true
            return []
        }
        hostEnvironment.addGlobal(name: "start_string", value: .i32(0))
        let moduleInstance = runtime.instanciate(module: wasm.module, hostEnvironment: hostEnvironment)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "helloworld", arguments: [], result: &result)
        XCTAssertTrue(printStringCalled)
    }

    func testFizzBuzz() throws {
        let fileURL = Bundle.module.url(forResource: "fizzbuzz", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let hostEnvironment = HostEnvironment()
        var printedStrings: [String] = []
        hostEnvironment.addCode(name: "print_value") { arguments in
            switch arguments.first {
            case let .i32(value):
                printedStrings.append("\(value)")
            default:
                XCTFail()
            }
            return []
        }
        hostEnvironment.addCode(name: "print_string") { arguments in
            let values = arguments.compactMap { argument in
                switch argument {
                case let .i32(value):
                    return value
                default:
                    return nil
                }
            }
            guard values.count == 2 else {
                fatalError("Unexpected error")
            }

            let stringData = hostEnvironment.memory.data[values[1]..<(values[1] + values[0])]
            guard let string = String(data: stringData, encoding: .utf8) else {
                fatalError("Unexpected error")
            }
            printedStrings.append(string)
            return []
        }
        let moduleInstance = runtime.instanciate(module: wasm.module, hostEnvironment: hostEnvironment)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "fizzbuzz", arguments: [.i32(31)], result: &result)
        XCTAssertEqual(printedStrings, ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz", "16", "17", "Fizz", "19", "Buzz", "Fizz", "22", "23", "Fizz", "Buzz", "26", "Fizz", "28", "29", "FizzBuzz"])
    }

    func testMemoryAccumulate() throws {
        let fileURL = Bundle.module.url(forResource: "memory_accumulate", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        runtime.store.write(memoryAddress: 0, bytes: [0x00, 0x00, 0x00, 0x00,
                                                      0x01, 0x00, 0x00, 0x00,
                                                      0x02, 0x00, 0x00, 0x00,
                                                      0x03, 0x00, 0x00, 0x00,
                                                      0x04, 0x00, 0x00, 0x00,
                                                      0x05, 0x00, 0x00, 0x00,
                                                      0x06, 0x00, 0x00, 0x00,
                                                      0x07, 0x00, 0x00, 0x00,
                                                      0x08, 0x00, 0x00, 0x00,
                                                      0x09, 0x00, 0x00, 0x00], offset: 10)
        var result: Value?

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "accumulate", arguments: [.i32(10), .i32(20)], result: &result)
        XCTAssertEqual(result, .i32(45))
    }

    func testTable() throws {
        let fileURL = Bundle.module.url(forResource: "table", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        let runtime = Runtime()
        let moduleInstance = runtime.instanciate(module: wasm.module)
        var result: Value?
        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "TestIncrementGlobal", arguments: [], result: &result)
        XCTAssertEqual(result, .i32(1))

        try runtime.invoke(moduleInstance: moduleInstance,
                           functionName: "TestSquare", arguments: [.i32(4)], result: &result)
        XCTAssertEqual(result, .i32(16))
    }
}
