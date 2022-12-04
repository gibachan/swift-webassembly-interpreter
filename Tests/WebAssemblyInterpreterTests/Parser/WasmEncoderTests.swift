//
//  WasmEncoderTests.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/13.
//

import XCTest
import Foundation
@testable import WebAssemblyInterpreter

final class WasmEncoderTests: XCTestCase {
    func testEncodeModule() throws {
        let fileName = "module"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeFunc() throws {
        let fileName = "func"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeFuncParameter() throws {
        let fileName = "func_parameter"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeFuncReturnConst() throws {
        let fileName = "func_return_const"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeFuncExport() throws {
        let fileName = "func_export"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeFuncLoop() throws {
        let fileName = "func_loop"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeFuncAddInt() throws {
        let fileName = "func_add_int"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeFuncReturnSumSquared() throws {
        let fileName = "func_return_sum_squared"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeGlobal() throws {
        let fileName = "global"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeMutableGlobal() throws {
        let fileName = "mutable_global"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
    
    func testEncodeImportFunction() throws {
        let fileName = "import_function"
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()
        
        let encoder = WasmEncoder(wasm: wasm)
        let encoded = try encoder.invoke()
        
        XCTAssertEqual(encoded, decodeWasm(fileName: fileName))
    }
}

private extension WasmEncoderTests {
    func decodeWasm(fileName: String) -> Data {
        let fileURL = Bundle.module.url(forResource: fileName, withExtension: "wasm")!
        let filePath = fileURL.path
        let fileHandle = FileHandle(forReadingAtPath: filePath)!
        defer { fileHandle.closeFile() }
        return try! fileHandle.readToEnd()!
    }
}
