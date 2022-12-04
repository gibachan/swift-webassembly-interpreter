//
//  StringExtensionTests.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/13.
//

import XCTest
@testable import WebAssemblyInterpreter

final class StringExtensionTests: XCTestCase {
    func testEncode() {
        XCTAssertEqual("run".encode(), [0x03, 0x72, 0x75, 0x6E])
    }
}
