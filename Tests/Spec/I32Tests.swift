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
        throw XCTSkip("Not ready for i32.wast test cases")

        guard let wast = decodeWastJSON(fileName: "i32.wast") else {
            XCTFail()
            return
        }

        guard let command = wast.commands.first else {
            return
        }

        switch command.type {
        case .module:
            testModule(command: command)
        default:
            XCTFail("Not Implemented yet")
        }
    }
}
