//
//  XCTestCaseExtension.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/01/17.
//

@testable import WebAssemblyInterpreter
import XCTest

extension XCTestCase {
    func testModule(command: Wast.Command,
                    file: StaticString = #filePath,
                    line: UInt = #line) {
        guard let filename = command.filename else {
            XCTFail("filename is missing")
            return
        }

        do {
            let fileURL = Bundle.module.url(forResource: filename, withExtension: "")!
            let filePath = fileURL.path
            let decoder = try WasmDecoder(filePath: filePath)
            _ = try decoder.invoke()
        } catch {
            XCTFail("\(error)", file: file, line: line)
            return
        }
    }
}
