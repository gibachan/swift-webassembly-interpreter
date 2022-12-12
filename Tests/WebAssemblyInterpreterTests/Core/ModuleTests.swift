//
//  ModuleTests.swift
//
//
//  Created by Tatsuyuki Kobayashi on 2022/11/26.
//

@testable import WebAssemblyInterpreter
import XCTest

final class ModuleTests: XCTestCase {
    func testFindExportedFunctionFail() {
        let module = Module(typeSection: .init(sectionID: Section.type.rawValue,
                                               size: 1,
                                               functionTypes: .init(length: 1,
                                                                    elements: [.init(parameterTypes: .init(valueTypes: .init(length: 2, elements: [.number(.i32), .number(.i32)])),
                                                                                     resultTypes: .init(valueTypes: .init(length: 1, elements: [.number(.i32)])))])),
                            importSection: nil,
                            functionSection: .init(sectionID: Section.function.rawValue,
                                                   size: 1,
                                                   indices: .init(length: 1, elements: [0])),
                            globalSection: nil,
                            exportSection: .init(sectionID: Section.export.rawValue,
                                                 size: 1,
                                                 exports: .init(length: 1, elements: [.init(name: "hoge", descriptor: .function(0))])),
                            codeSection: nil
        )

        XCTAssertNil(module.findExportedFunction(withName: "piyo"))
    }
}
