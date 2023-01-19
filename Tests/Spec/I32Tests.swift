//
//  I32Tests.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/01/17.
//

@testable import WebAssemblyInterpreter
import XCTest

final class I32Tests: XCTestCase {
    func testI32Wast() throws {
        guard let wast = decodeWastJSON(fileName: "i32.wast") else {
            XCTFail()
            return
        }

        var wasm: Wasm!
        wast.commands.prefix(97).forEach { command in
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
