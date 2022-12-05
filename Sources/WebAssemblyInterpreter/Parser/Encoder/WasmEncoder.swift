//
//  WasmEncoder.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/19.
//

import Foundation

public struct WasmEncoder {
    private let wasm: Wasm
    
    public init(wasm: Wasm) {
        self.wasm = wasm
    }
}

public extension WasmEncoder {
    func invoke() throws -> Data {
        return encodeModule(wasm.module)
    }
}

private extension WasmEncoder {
    func encodeModule(_ module: Module) -> Data {
        var bytes: [Byte] = []
        
        Module.magicNumber.forEach { bytes.append($0) }
        Module.version.forEach { bytes.append($0) }
        
        if let typeSection = module.typeSection {
            encodeTypeSection(typeSection).forEach {
                bytes.append($0)
            }
        }
        if let importSection = module.importSection {
            encodeImportSection(importSection).forEach {
                bytes.append($0)
            }
        }
        if let functionSection = module.functionSection {
            encodeFunctionSection(functionSection).forEach {
                bytes.append($0)
            }
        }
        if let globalSection = module.globalSection {
            encodeGlobalSection(globalSection).forEach {
                bytes.append($0)
            }
        }
        if let exportSection = module.exportSection {
            encodeExportSection(exportSection).forEach {
                bytes.append($0)
            }
        }
        if let codeSection = module.codeSection {
            encodeCodeSection(codeSection).forEach {
                bytes.append($0)
            }
        }
        
        return Data(bytes)
    }
    
    func encodeTypeSection(_ section: TypeSection) -> [Byte] {
        var bytes: [Byte] = []
        bytes.append(section.sectionID)
        section.size.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.functionTypes.length.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.functionTypes.elements
            .forEach { functionType in
                bytes.append(FunctionType.id)
                encodeResultType(functionType.resultType1)
                    .forEach { bytes.append($0) }
                encodeResultType(functionType.resultType2)
                    .forEach { bytes.append($0) }
            }
        return bytes
    }
    
    func encodeResultType(_ resultType: ResultType) -> [Byte] {
        var bytes: [Byte] = []
        resultType.valueTypes.length.unsignedLEB128.forEach {
            bytes.append($0)
        }
        resultType.valueTypes.elements.forEach { valueType in
            switch valueType {
            case let .number(numberType):
                bytes.append(numberType.rawValue)
            case let .vector(vectorType):
                bytes.append(vectorType.rawValue)
            case let .reference(referenceType):
                bytes.append(referenceType.rawValue)
            }
        }
        return bytes
    }
    
    func encodeImportSection(_ section: ImportSection) -> [Byte] {
        var bytes: [Byte] = []
        bytes.append(section.sectionID)
        section.size.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.imports.length.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.imports.elements
            .forEach { `import` in
                UInt(`import`.module.count).unsignedLEB128.forEach {
                    bytes.append($0)
                }
                `import`.module.data(using: .utf8)?.forEach {
                    bytes.append($0)
                }
                UInt(`import`.name.count).unsignedLEB128.forEach {
                    bytes.append($0)
                }
                `import`.name.data(using: .utf8)?.forEach {
                    bytes.append($0)
                }
                bytes.append(`import`.descriptor.type.rawValue)
                switch `import`.descriptor {
                case let .function(typeIndex):
                    typeIndex.unsignedLEB128.forEach {
                        bytes.append($0)
                    }
                case let .global(globalType):
                    encodeGlobalType(globalType).forEach {
                        bytes.append($0)
                    }

                }
            }
        return bytes
    }
    
    func encodeFunctionSection(_ section: FunctionSection) -> [Byte] {
        var bytes: [Byte] = []
        bytes.append(section.sectionID)
        section.size.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.indices.length.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.indices.elements
            .forEach { index in
                index.unsignedLEB128.forEach {
                    bytes.append($0)
                }
            }
        return bytes
    }
    
    func encodeGlobalSection(_ section: GlobalSection) -> [Byte] {
        var bytes: [Byte] = []
        bytes.append(section.sectionID)
        section.size.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.globals.length.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.globals.elements
            .forEach { global in
                encodeGlobal(global).forEach {
                    bytes.append($0)
                }
            }
        return bytes
    }
    
    func encodeGlobal(_ global: GlobalSection.Global) -> [Byte] {
        var bytes: [Byte] = []
        encodeGlobalType(global.type).forEach {
            bytes.append($0)
        }
        encodeExpression(global.expression).forEach {
            bytes.append($0)
        }
        return bytes
    }
    
    func encodeGlobalType(_ globalType: GlobalType) -> [Byte] {
        var bytes: [Byte] = []
        encodeValueType(globalType.valueType).forEach {
            bytes.append($0)
        }
        bytes.append(globalType.mutability.rawValue)
        return bytes
    }
    
    func encodeExportSection(_ section: ExportSection) -> [Byte] {
        var bytes: [Byte] = []
        bytes.append(section.sectionID)
        section.size.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.exports.length.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.exports.elements
            .forEach { export in
                UInt(export.name.count).unsignedLEB128.forEach {
                    bytes.append($0)
                }
                export.name.data(using: .utf8)?.forEach {
                    bytes.append($0)
                }
                switch export.descriptor {
                case let .function(index):
                    bytes.append(ExportSection.ExportDescriptorType.functionIndex.rawValue)
                    index.unsignedLEB128.forEach {
                        bytes.append($0)
                    }
                case .table(_):
                    fatalError("Not implemented yet")
                case .memory(_):
                    fatalError("Not implemented yet")
                case .global(_):
                    fatalError("Not implemented yet")
                }
            }
        return bytes
    }
    
    func encodeCodeSection(_ section: CodeSection) -> [Byte] {
        var bytes: [Byte] = []
        bytes.append(section.sectionID)
        section.size.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.codes.length.unsignedLEB128.forEach {
            bytes.append($0)
        }
        section.codes.elements
            .forEach { code in
                code.size.unsignedLEB128.forEach {
                    bytes.append($0)
                }
                UInt(code.locals.count).unsignedLEB128.forEach {
                    bytes.append($0)
                }
                code.locals.forEach { valueType in
                    // Not sure if it is always UInt8(1)
                    UInt8(1).unsignedLEB128.forEach {
                        bytes.append($0)
                    }
                    
                    encodeValueType(valueType).forEach {
                        bytes.append($0)
                    }
                }
                encodeExpression(code.expression).forEach {
                    bytes.append($0)
                }
            }
        return bytes
    }
    
    func encodeExpression(_ expression: Expression) -> [Byte] {
        var bytes: [Byte] = []
        expression.instructions.forEach { instruction in
            bytes.append(instruction.id.rawValue)

            switch instruction {
            case let .block(blockType):
                encodeBlockType(blockType).forEach {
                    bytes.append($0)
                }
            case let .loop(blockType):
                encodeBlockType(blockType).forEach {
                    bytes.append($0)
                }
            case let .if(blockType):
                encodeBlockType(blockType).forEach {
                    bytes.append($0)
                }
            case let .br(labelIndex):
                labelIndex.unsignedLEB128.forEach {
                    bytes.append($0)
                }
            case let .brIf(labelIndex):
                labelIndex.unsignedLEB128.forEach {
                    bytes.append($0)
                }
            case let .call(functionIndex):
                functionIndex.unsignedLEB128.forEach {
                    bytes.append($0)
                }

            case let .localGet(index):
                index.unsignedLEB128.forEach {
                    bytes.append($0)
                }
            case let .localSet(index):
                index.unsignedLEB128.forEach {
                    bytes.append($0)
                }
            case let .localTee(index):
                index.unsignedLEB128.forEach {
                    bytes.append($0)
                }
            case let .globalGet(index):
                index.unsignedLEB128.forEach {
                    bytes.append($0)
                }
            case let .globalSet(index):
                index.unsignedLEB128.forEach {
                    bytes.append($0)
                }

            case let .i32Const(value):
                value.signedLEB128.forEach {
                    bytes.append($0)
                }
            // Control InstructionsI
            case .unreachable, .nop:
                break
            // Variable Instructions
            case .f32Add:
                break
            // Numeric Instruction
            case .i64Const, .f32Const, .f64Const, .i32Eq, .i32GeU, .i32Add, .i32Sub, .i32Mul:
                break
            // Expressions
            case .end:
                break
            }
        }
        return bytes
    }
    
    func encodeBlockType(_ blockType: BlockType) -> [Byte] {
        switch blockType {
        case .empty:
            return [BlockType.emptyByte]
        case let .value(valueType):
            return encodeValueType(valueType)
        }
    }
    
    func encodeValueType(_ valeuType: ValueType) -> [Byte] {
        switch valeuType {
        case let .number(type):
            return [type.rawValue]
        case let .vector(type):
            return [type.rawValue]
        case let .reference(type):
            return [type.rawValue]
        }
    }
}