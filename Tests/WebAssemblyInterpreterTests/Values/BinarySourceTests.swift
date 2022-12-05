//
//  BinarySourceTests.swift
//
//
//  Created by Tatsuyuki Kobayashi on 2022/11/17.
//

@testable import WebAssemblyInterpreter
import XCTest

final class BinarySourceTests: XCTestCase {
    func testEmptyBytes() {
        let source = BinarySource(data: Data())

        XCTAssertEqual(source.count, 0)
    }

    func testSubscript() {
        let source = BinarySource(data: Data([0x00, 0x01, 0x02, 0x03, 0x04]))

        XCTAssertEqual(source[0], UInt8(0x00))
        XCTAssertEqual(source[1], UInt8(0x01))
        XCTAssertEqual(source[2], UInt8(0x02))
        XCTAssertEqual(source[3], UInt8(0x03))
        XCTAssertEqual(source[4], UInt8(0x04))
    }

    func testMove() {
        let source = BinarySource(data: Data([0x00, 0x01, 0x02, 0x03, 0x04]))

        XCTAssertEqual(source.current, UInt8(0x00))

        source.move(4)

        XCTAssertEqual(source.current, UInt8(0x04))

        source.move(-2)

        XCTAssertEqual(source.current, UInt8(0x02))
    }

    func testConsumeWithCount() {
        let source = BinarySource(data: Data([0x00, 0x01, 0x02, 0x03, 0x04]))

        XCTAssertEqual(source.consume(2), Data([0x00, 0x01]))
        XCTAssertEqual(source.current, UInt8(0x02))

        XCTAssertEqual(source.consume(3), Data([0x02, 0x03, 0x04]))
        XCTAssertNil(source.current)

        XCTAssertNil(source.consume(1))
    }

    func testRemaining() {
        let source = BinarySource(data: Data([0x00, 0x01, 0x02, 0x03, 0x04]))

        source.consume(2)

        XCTAssertEqual(source.remaining, 3)
    }

    func testPeek() {
        let source = BinarySource(data: Data([0x01, 0x02, 0x03]))

        XCTAssertEqual(source.current, 0x01)
        XCTAssertEqual(source.peek(), 0x02)
        XCTAssertEqual(source.current, 0x01)

        source.move(2)
        XCTAssertNil(source.peek())
    }

    func testConsume() {
        let source = BinarySource(data: Data([0x01, 0x02, 0x03]))

        XCTAssertEqual(source.consume(), 0x01)
        XCTAssertEqual(source.consume(), 0x02)
        XCTAssertEqual(source.consume(), 0x03)
        XCTAssertNil(source.consume())
    }
}
