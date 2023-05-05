//
//  I64Tests.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/05/05.
//

@testable import WebAssemblyInterpreter
import XCTest

final class I64Tests: XCTestCase {
    func testI64Wast() throws {
        guard let wast = decodeWastJSON(fileName: "i64.wast") else {
            XCTFail()
            return
        }

        var wasm: Wasm!

        wast.commands.forEach { command in
            switch command.type {
            case .module:
                wasm = testModule(command: command)
            case .assertReturn:
                testAssertReturn(wasm: wasm, command: command)
            default:
                // TODO: Implement
                break
            }
        }
    }
}
