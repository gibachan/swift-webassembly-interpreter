//
//  DateExtensionTests.swift
//
//
//  Created by Tatsuyuki Kobayashi on 2022/11/10.
//

import Foundation
@testable import WebAssemblyInterpreter
import XCTest

final class DateExtensionTests: XCTestCase {
    func testHexEncodedString() {
        let data = Data([0x00, 0x61, 0x73, 0x6D])

        XCTAssertEqual(data.hexEncodedString(options: [.upperCase]), "0061736D")
    }

    func testConsume() {
        var data = Data([0x48, 0x45, 0x4C, 0x4C, 0x4F, 0x00, 0x57, 0x4F, 0x52, 0x4C, 0x44])

        let hello = data.consume(bytes: 5)
        XCTAssertEqual(hello, Data([0x48, 0x45, 0x4C, 0x4C, 0x4F]))

        _ = data.consume(bytes: 1)
        let world = data.consume(bytes: 5)
        XCTAssertEqual(world, Data([0x57, 0x4F, 0x52, 0x4C, 0x44]))

        var data2 = Data([0x48])
        let tooMuchConsumed = data2.consume(bytes: 100)
        XCTAssertTrue(data2.isEmpty)
        XCTAssertNil(tooMuchConsumed)
    }

    func testUInt8() {
        XCTAssertEqual(Data([0x00]).uint8, 0)
        XCTAssertEqual(Data([0x01]).uint8, 1)
    }
    func testUInt16() {
        XCTAssertEqual(Data([0x00, 0x00]).uint16, 0)
        XCTAssertEqual(Data([0x01, 0x00]).uint16, 1)
    }
    func testUInt32() {
        XCTAssertEqual(Data([0x00, 0x00, 0x00, 0x00]).uint32, 0)
        XCTAssertEqual(Data([0x01, 0x00, 0x00, 0x00]).uint32, 1)
    }
    func testUInt64() {
        XCTAssertEqual(Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]).uint64, 0)
        XCTAssertEqual(Data([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]).uint64, 1)
    }
}
