//
//  XCTestCaseExtension.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/01/17.
//

@testable import WebAssemblyInterpreter
import XCTest

extension XCTestCase {
    @discardableResult
    func testModule(command: Wast.Command,
                    file: StaticString = #filePath,
                    line: UInt = #line) -> Wasm? {
        guard let filename = command.filename else {
            XCTFail("filename is missing")
            return nil
        }

        do {
            let fileURL = Bundle.module.url(forResource: filename, withExtension: "")!
            let filePath = fileURL.path
            let decoder = try WasmDecoder(filePath: filePath)
            return try decoder.invoke()
        } catch {
            XCTFail("Failed for \(command.filename ?? "Unknown file"): \(error)", file: file, line: line)
            return nil
        }
    }

    func testAssertReturn(wasm: Wasm,
                          command: Wast.Command,
                          file: StaticString = #filePath,
                          line: UInt = #line) {
        guard let action = command.action else {
            XCTFail("action is missing", file: file, line: line)
            return
        }
        guard action.type == "invoke" else {
            XCTFail("action type \(action.type) is not supported", file: file, line: line)
            return
        }

        do {
            let runtime = Runtime()
            let moduleInstance = runtime.instanciate(module: wasm.module)
            let arguments: [Value] = action.args.compactMap { value in
                switch value.type {
                case .i32:
                    return value.i32
                case .i64:
                    return value.i64
                default:
                    XCTFail("value type \(value.type) is not supported", file: file, line: line)
                    return nil
                }
            }
            let expected: [Value] = command.expected?.compactMap { value in
                switch value.type {
                case .i32:
                    return value.i32
                case .i64:
                    return value.i64
                default:
                    XCTFail("value type \(value.type) is not supported", file: file, line: line)
                    return nil
                }
            } ?? []

            var result: Value?

            try runtime.invoke(moduleInstance: moduleInstance,
                               functionName: action.field,
                               arguments: arguments,
                               result: &result)
            XCTAssertEqual(result, expected.first, "command=\(command)", file: file, line: line)
        } catch {
            XCTFail("Failed for \(command.filename ?? "Unknown file"): \(error)", file: file, line: line)
        }
    }
}
