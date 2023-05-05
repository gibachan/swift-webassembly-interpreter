//
//  BlockTests.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/05/05.
//

@testable import WebAssemblyInterpreter
import XCTest

final class BlockTests: XCTestCase {
    func testBlockWast() throws {
        guard let wast = decodeWastJSON(fileName: "block.wast") else {
            XCTFail()
            return
        }

        var wasm: Wasm!

        wast.commands.prefix(2).forEach { command in
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
