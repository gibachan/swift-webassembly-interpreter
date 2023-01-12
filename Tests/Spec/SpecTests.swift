@testable import WebAssemblyInterpreter
import XCTest

final class SpecTests: XCTestCase {
    func testConstWast() {
        guard let wast = decodeWastJSON(fileName: "const.wast") else {
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
