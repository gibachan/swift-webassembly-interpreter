//
//  UInt8ExtensionTests.swift
//
//
//  Created by Tatsuyuki Kobayashi on 2022/11/10.
//

import Foundation
@testable import WebAssemblyInterpreter
import XCTest

final class UInt8ExtensionTests: XCTestCase {
    func testHex() {
        XCTAssertEqual(UInt8.min.hex, "00")
        XCTAssertEqual(UInt8.max.hex, "FF")
    }
}
