@testable import WebAssemblyInterpreter
import XCTest

final class ConstTests: XCTestCase {
    func testtConstWast() {
        guard let wast = decodeWastJSON(fileName: "const.wast") else {
            XCTFail()
            return
        }

        let commands = wast.commands.prefix(5)
        commands.forEach { command in
            switch command.type {
            case .module:
                testModule(command: command)
            case .assertMalformed:
                // TODO: Implement
                break
            case .assertReturn:
                // TODO: Implement
                break
            case .assertTrap:
                // TODO: Implement
                break
            case .assertInvalid:
                // TODO: Implement
                break
            }
        }
    }
}
