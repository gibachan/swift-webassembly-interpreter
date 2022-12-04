//
//  TypesTests.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/03.
//

import XCTest
@testable import WebAssemblyInterpreter

final class TypesTests: XCTestCase {
    func testValueTypeFrom() {
        XCTAssertEqual(ValueType.from(byte: 0x7F), .number(.i32))
        XCTAssertEqual(ValueType.from(byte: 0x7B), .vector(.v128))
        XCTAssertEqual(ValueType.from(byte: 0x70), .reference(.function))
        XCTAssertNil(ValueType.from(byte: 0x00))
    }
}
