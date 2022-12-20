//
//  WasmEncoderTests.swift
//
//
//  Created by Tatsuyuki Kobayashi on 2022/11/13.
//

import Foundation
@testable import WebAssemblyInterpreter
import XCTest

final class WasmEncoderTests: XCTestCase {
    func testEncodeModule() throws {
        let fileName = "module"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeFunc() throws {
        let fileName = "func"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeFuncParameter() throws {
        let fileName = "func_parameter"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeFuncReturnConst() throws {
        let fileName = "func_return_const"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeFuncExport() throws {
        let fileName = "func_export"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeFuncLoop() throws {
        let fileName = "func_loop"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeFuncAddInt() throws {
        let fileName = "func_add_int"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeFuncReturnSumSquared() throws {
        let fileName = "func_return_sum_squared"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeMemory() throws {
        let fileName = "memory"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeGlobal() throws {
        let fileName = "global"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeMutableGlobal() throws {
        let fileName = "mutable_global"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeImportFunction() throws {
        let fileName = "import_function"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeIsPrime() throws {
        let fileName = "is_prime"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeStart() throws {
        let fileName = "start"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }

    func testEncodeHelloWorld() throws {
        let fileName = "helloworld"
        let decoder = try WasmDecoder(filePath: path(for: fileName))
        let wasm = try decoder.invoke()

        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()

        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
}

private extension WasmEncoderTests {
    func path(for fileName: String) -> String {
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        return fileURL.path
    }

    func decodeWasm(fileName: String) -> Data {
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let fileHandle = FileHandle(forReadingAtPath: filePath)!
        defer { fileHandle.closeFile() }
        // swiftlint:disable:next force_try
        return try! fileHandle.readToEnd()!
    }
}
