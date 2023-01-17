@testable import WebAssemblyInterpreter
import XCTest

final class ConstTests: XCTestCase {
    func testtConstWast() {
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
