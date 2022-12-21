import Foundation
@testable import WebAssemblyInterpreter
import XCTest

final class WasmDecoderTests: XCTestCase {
    func testDecodeModule() throws {
        let fileURL = Bundle.module.url(forResource: "module", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNil(wasm.module.typeSection)
        XCTAssertNil(wasm.module.functionSection)
        XCTAssertNil(wasm.module.exportSection)
        XCTAssertNil(wasm.module.codeSection)
    }

    func testDecodeFunc() throws {
        let fileURL = Bundle.module.url(forResource: "func", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.typeSection)
        XCTAssertNotNil(wasm.module.functionSection)
        XCTAssertNil(wasm.module.exportSection)
        XCTAssertNotNil(wasm.module.codeSection)
    }

    func testDecodeFuncParameter() throws {
        let fileURL = Bundle.module.url(forResource: "func_parameter", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.typeSection)
        XCTAssertNotNil(wasm.module.functionSection)
        XCTAssertNil(wasm.module.exportSection)
        XCTAssertNotNil(wasm.module.codeSection)

        // type section
        guard let typeSection = wasm.module.typeSection else {
            XCTFail("Type section is missing")
            return
        }
        XCTAssertEqual(typeSection.size, 6)
        XCTAssertEqual(typeSection.functionTypes.length, 1)
        guard let functionType = typeSection.functionTypes.elements.first else {
            XCTFail("Function type is missing")
            return
        }
        XCTAssertEqual(functionType.parameterTypes.valueTypes.length, 2)
        let valueType1 = functionType.parameterTypes.valueTypes.elements[0]
        if case .number(let type) = valueType1 {
            if case .i32 = type {
                // OK
            } else {
                XCTFail("Wrong value type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }
        let valueType2 = functionType.parameterTypes.valueTypes.elements[1]
        if case .number(let type) = valueType2 {
            if case .f32 = type {
                // OK
            } else {
                XCTFail("Wrong value type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }
        XCTAssertEqual(functionType.resultTypes.valueTypes.length, 0)
    }

    func testDecodeFuncLocal() throws {
        let fileURL = Bundle.module.url(forResource: "func_local", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        guard let codeSection = wasm.module.codeSection else {
            XCTFail("Code section is missing")
            return
        }

        XCTAssertEqual(codeSection.codes.length, 1)

        guard let code = codeSection.codes.elements.first else {
            XCTFail("Code is missing")
            return
        }

        XCTAssertEqual(code.locals.count, 3)
    }

    func testDecodeFuncReturnConst() throws {
        let fileURL = Bundle.module.url(forResource: "func_return_const", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.typeSection)
        XCTAssertNotNil(wasm.module.functionSection)
        XCTAssertNil(wasm.module.exportSection)
        XCTAssertNotNil(wasm.module.codeSection)

        // code section
        guard let codeSection = wasm.module.codeSection else {
            XCTFail("Code section is missing")
            return
        }
        XCTAssertEqual(codeSection.size, 6)
        XCTAssertEqual(codeSection.codes.length, 1)
        XCTAssertEqual(codeSection.codes.elements.count, 1)
        guard let code = codeSection.codes.elements.first else {
            XCTFail("Code is missing")
            return
        }
        XCTAssertEqual(code.size, 4)
        XCTAssertEqual(code.locals.count, 0)
        XCTAssertEqual(code.expression.instructions.count, 2)
        if case let .i32Const(value) = code.expression.instructions[0] {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("i32.const is missing")
            return
        }
        if case .end = code.expression.instructions[1] {
            // Noop
        } else {
            XCTFail("end is missing")
            return
        }
    }

    func testDecodeFuncExport() throws {
        let fileURL = Bundle.module.url(forResource: "func_export", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.typeSection)
        XCTAssertNotNil(wasm.module.functionSection)
        XCTAssertNotNil(wasm.module.exportSection)
        XCTAssertNotNil(wasm.module.codeSection)

        // code section
        guard let codeSection = wasm.module.codeSection else {
            XCTFail("Code section is missing")
            return
        }
        XCTAssertEqual(codeSection.codes.length, 1)
        XCTAssertEqual(codeSection.codes.elements.count, 1)
        guard let code = codeSection.codes.elements.first else {
            XCTFail("Code is missing")
            return
        }
        XCTAssertEqual(code.size, 2)
        XCTAssertEqual(code.locals.count, 0)
        XCTAssertEqual(code.expression.instructions.count, 1) // end

        // export section
        guard let exportSection = wasm.module.exportSection else {
            XCTFail("Export section is missing")
            return
        }
        XCTAssertEqual(exportSection.size, 10)
        XCTAssertEqual(exportSection.exports.elements.count, 1)
        guard let export = exportSection.exports.elements.first else {
            XCTFail("Export is missing")
            return
        }
        XCTAssertEqual(export.name, "MyFunc")
        if case .function(let index) = export.descriptor {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Wrong export descriptor")
        }
    }

    func testDecodeFuncLoop() throws {
        let fileURL = Bundle.module.url(forResource: "func_loop", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.codeSection)
    }

    func testDecodeFuncAddInt() throws {
        let fileURL = Bundle.module.url(forResource: "func_add_int", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.typeSection)
        XCTAssertNotNil(wasm.module.functionSection)
        XCTAssertNotNil(wasm.module.exportSection)
        XCTAssertNotNil(wasm.module.codeSection)

        // type section
        guard let typeSection = wasm.module.typeSection else {
            XCTFail("Type section is missing")
            return
        }
        guard let parameterTypes = typeSection.functionTypes.elements.first?.parameterTypes.valueTypes.elements else {
            XCTFail("parameterTypes are missing")
            return
        }
        XCTAssertEqual(parameterTypes.count, 2)
        let parameterType1 = parameterTypes[0]
        if case .number(let type) = parameterType1 {
            if case .i32 = type {
                // OK
            } else {
                XCTFail("Wrong value type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }
        let parameterType2 = parameterTypes[1]
        if case .number(let type) = parameterType2 {
            if case .i32 = type {
                // OK
            } else {
                XCTFail("Wrong value type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }
        guard let returnTypes = typeSection.functionTypes.elements.first?.resultTypes.valueTypes.elements else {
            XCTFail("ReturnTypes are missing")
            return
        }
        XCTAssertEqual(returnTypes.count, 1)
        let returnType = returnTypes[0]
        if case .number(let type) = returnType {
            if case .i32 = type {
                // OK
            } else {
                XCTFail("Wrong return type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }

        // code section
        guard let codeSection = wasm.module.codeSection else {
            XCTFail("Code section is missing")
            return
        }
        XCTAssertEqual(codeSection.codes.length, 1)
        XCTAssertEqual(codeSection.codes.elements.count, 1)
        guard let code = codeSection.codes.elements.first else {
            XCTFail("Code is missing")
            return
        }
        XCTAssertEqual(code.size, 7)
        XCTAssertEqual(code.locals.count, 0)
        XCTAssertEqual(code.expression.instructions.count, 4)

        let getLocal1 = code.expression.instructions[0]
        if case .localGet(let index) = getLocal1 {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("local.get instruction is missing")
            return
        }
        let getLocal2 = code.expression.instructions[1]
        if case .localGet(let index) = getLocal2 {
            XCTAssertEqual(index, 1)
        } else {
            XCTFail("local.get instruction is missing")
            return
        }
        let i32Add = code.expression.instructions[2]
        if case .i32Add = i32Add {
            // OK
        } else {
            XCTFail("i32.add instruction is missing")
            return
        }
        let end = code.expression.instructions[3]
        if case .end = end {
            // OK
        } else {
            XCTFail("end instruction is missing")
            return
        }

        // export section
        guard let exportSection = wasm.module.exportSection else {
            XCTFail("Export section is missing")
            return
        }
        XCTAssertEqual(exportSection.size, 10)
        XCTAssertEqual(exportSection.exports.elements.count, 1)
        guard let export = exportSection.exports.elements.first else {
            XCTFail("Export is missing")
            return
        }
        XCTAssertEqual(export.name, "AddInt")
        if case .function(let index) = export.descriptor {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Wrong export descriptor")
        }
    }

    func testDecodeFuncReturnSumSquared() throws {
        let fileURL = Bundle.module.url(forResource: "func_return_sum_squared", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.typeSection)
        XCTAssertNotNil(wasm.module.functionSection)
        XCTAssertNotNil(wasm.module.exportSection)
        XCTAssertNotNil(wasm.module.codeSection)

        // type section
        guard let typeSection = wasm.module.typeSection else {
            XCTFail("Type section is missing")
            return
        }
        guard let parameterTypes = typeSection.functionTypes.elements.first?.parameterTypes.valueTypes.elements else {
            XCTFail("parameterTypes are missing")
            return
        }
        XCTAssertEqual(parameterTypes.count, 2)
        let parameterType1 = parameterTypes[0]
        if case .number(let type) = parameterType1 {
            if case .i32 = type {
                // OK
            } else {
                XCTFail("Wrong value type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }
        let parameterType2 = parameterTypes[1]
        if case .number(let type) = parameterType2 {
            if case .i32 = type {
                // OK
            } else {
                XCTFail("Wrong value type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }
        guard let returnTypes = typeSection.functionTypes.elements.first?.resultTypes.valueTypes.elements else {
            XCTFail("ReturnTypes are missing")
            return
        }
        XCTAssertEqual(returnTypes.count, 1)
        let returnType = returnTypes[0]
        if case .number(let type) = returnType {
            if case .i32 = type {
                // OK
            } else {
                XCTFail("Wrong return type")
                return
            }
        } else {
            XCTFail("Number type is missing")
            return
        }

        // code section
        guard let codeSection = wasm.module.codeSection else {
            XCTFail("Code section is missing")
            return
        }
        XCTAssertEqual(codeSection.codes.length, 1)
        XCTAssertEqual(codeSection.codes.elements.count, 1)
        guard let code = codeSection.codes.elements.first else {
            XCTFail("Code is missing")
            return
        }
        XCTAssertEqual(code.size, 16)

        // Local
        XCTAssertEqual(code.locals.count, 1)
        guard let local = code.locals.first else {
            XCTFail("Local is missing")
            return
        }
        guard case let .number(valueType) = local else {
            XCTFail("Wrong local")
            return
        }
        XCTAssertEqual(valueType, .i32)

        // Instructions
        XCTAssertEqual(code.expression.instructions.count, 8)
        let localGet1 = code.expression.instructions[0]
        if case let .localGet(index) = localGet1 {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("local.get instruction is missing")
            return
        }
        let localGet2 = code.expression.instructions[1]
        if case let .localGet(index) = localGet2 {
            XCTAssertEqual(index, 1)
        } else {
            XCTFail("local.get instruction is missing")
            return
        }
        let i32Add = code.expression.instructions[2]
        if case .i32Add = i32Add {
            // OK
        } else {
            XCTFail("i32.add instruction is missing")
            return
        }
        let localSet = code.expression.instructions[3]
        if case let .localSet(index) = localSet {
            XCTAssertEqual(index, 2)
        } else {
            XCTFail("local.set instruction is missing")
            return
        }
        let localGet3 = code.expression.instructions[4]
        if case let .localGet(index) = localGet3 {
            XCTAssertEqual(index, 2)
        } else {
            XCTFail("local.get instruction is missing")
            return
        }
        let localGet4 = code.expression.instructions[5]
        if case let .localGet(index) = localGet4 {
            XCTAssertEqual(index, 2)
        } else {
            XCTFail("local.get instruction is missing")
            return
        }
        let i32Mul = code.expression.instructions[6]
        if case .i32Mul = i32Mul {
            // OK
        } else {
            XCTFail("i32.mul instruction is missing")
            return
        }
        let end = code.expression.instructions[7]
        if case .end = end {
            // OK
        } else {
            XCTFail("end instruction is missing")
            return
        }

        // export section
        guard let exportSection = wasm.module.exportSection else {
            XCTFail("Export section is missing")
            return
        }
        XCTAssertEqual(exportSection.size, 14)
        XCTAssertEqual(exportSection.exports.elements.count, 1)
        guard let export = exportSection.exports.elements.first else {
            XCTFail("Export is missing")
            return
        }
        XCTAssertEqual(export.name, "SumSquared")
        if case .function(let index) = export.descriptor {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Wrong export descriptor")
        }
    }

    func testDecodeTable() throws {
        let fileURL = Bundle.module.url(forResource: "table", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        guard let tableSection = wasm.module.tableSection else {
            XCTFail("Table section is missing")
            return
        }
        XCTAssertEqual(tableSection.tableTypes.length, 1)

        guard let tableType = tableSection.tableTypes.elements.first else {
            XCTFail("TableType is missing")
            return
        }
        XCTAssertEqual(tableType, TableType(referenceType: .function, limits: .min(n: 0)))
    }

    func testDecodeMemory() throws {
        let fileURL = Bundle.module.url(forResource: "memory", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        guard let memorySection = wasm.module.memorySection else {
            XCTFail("Memory section is missing")
            return
        }
        XCTAssertEqual(memorySection.memoryTypes.length, 1)

        guard let memoryType = memorySection.memoryTypes.elements.first else {
            XCTFail("MemoryType is missing")
            return
        }
        XCTAssertEqual(memoryType, MemoryType.min(n: 1))
    }

    func testDecodeGlobal() throws {
        let fileURL = Bundle.module.url(forResource: "global", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        guard let globalSection = wasm.module.globalSection else {
            XCTFail("Global section is missing")
            return
        }

        XCTAssertEqual(globalSection.globals.length, 1)

        guard let global = globalSection.globals.elements.first else {
            XCTFail("Global is missing")
            return
        }

        XCTAssertEqual(global.type.valueType, .number(.i32))
        XCTAssertEqual(global.type.mutability, .const)
    }

    func testDecodeMutableGlobal() throws {
        let fileURL = Bundle.module.url(forResource: "mutable_global", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        guard let globalSection = wasm.module.globalSection else {
            XCTFail("Global section is missing")
            return
        }

        XCTAssertEqual(globalSection.globals.length, 1)

        guard let global = globalSection.globals.elements.first else {
            XCTFail("Global is missing")
            return
        }

        XCTAssertEqual(global.type.valueType, .number(.i32))
        XCTAssertEqual(global.type.mutability, .var)
    }

    func testDecodeImportFunction() throws {
        let fileURL = Bundle.module.url(forResource: "import_function", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        guard let importSection = wasm.module.importSection else {
            XCTFail("Import section is missing")
            return
        }

        XCTAssertEqual(importSection.imports.length, 2)

        let import1 = importSection.imports.elements[0]
        let import2 = importSection.imports.elements[1]

        XCTAssertEqual(import1.module, "env")
        XCTAssertEqual(import1.name, "increment")
        XCTAssertEqual(import2.module, "env")
        XCTAssertEqual(import2.name, "decrement")
    }

    func testStart() throws {
        let fileURL = Bundle.module.url(forResource: "start", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertNotNil(wasm.module.typeSection)
        XCTAssertNotNil(wasm.module.functionSection)
        XCTAssertNil(wasm.module.exportSection)
        XCTAssertNotNil(wasm.module.startSection)
        XCTAssertNotNil(wasm.module.codeSection)
    }

    func testHelloWorld() throws {
        let fileURL = Bundle.module.url(forResource: "helloworld", withExtension: "wasm")!
        let filePath = fileURL.path
        let decoder = try WasmDecoder(filePath: filePath)
        let wasm = try decoder.invoke()

        XCTAssertEqual(wasm.module.importSection!.imports.length, 3)
        let import1 = wasm.module.importSection!.imports.elements[0]
        let import2 = wasm.module.importSection!.imports.elements[1]
        let import3 = wasm.module.importSection!.imports.elements[2]
        XCTAssertEqual(import1.name, "print_string")
        XCTAssertEqual(import2.name, "buffer")
        XCTAssertEqual(import3.name, "start_string")

        XCTAssertEqual(wasm.module.globalSection!.globals.length, 1)
        let global = wasm.module.globalSection!.globals.elements[0]
        XCTAssertEqual(global.type.valueType, .number(.i32))

        XCTAssertEqual(wasm.module.dataSection!.datas.length, 1)
        let data = wasm.module.dataSection!.datas.elements.first!
        XCTAssertEqual(data.memoryIndex, 0)
        XCTAssertEqual(data.initializer.length, 12)
    }
}
