@testable import WebAssemblyInterpreter
import XCTest

final class SpecTests: XCTestCase {
    func testExample() {
        let fileURL = Bundle.module.url(forResource: "const.wast", withExtension: "json")!
        let filePath = fileURL.path
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            XCTFail()
            return
        }
        defer { fileHandle.closeFile() }

        do {
            guard let data = try fileHandle.readToEnd() else {
                XCTFail()
                return
            }
            print(String(data: data, encoding: .utf8)!)

            XCTAssertEqual(1 + 1, 2)
        } catch {
            XCTFail()
        }
    }
}
