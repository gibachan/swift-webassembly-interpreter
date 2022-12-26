//
//  WasmDecoder.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/19.
//

import Foundation

public struct WasmDecoder {
    private let source: BinarySource
    
    public init(filePath: String) throws {
        self.source = try Self.readFile(filePath: filePath)
    }
}

public extension WasmDecoder {
    func invoke() throws -> Wasm {
        let module = try decodeModule()
        return Wasm(module: module)
    }
}

private extension WasmDecoder {
    static func readFile(filePath: String) throws -> BinarySource {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            throw WasmDecodeError.fileNotFound
        }
        defer { fileHandle.closeFile() }
        
        do {
            guard let _data = try fileHandle.readToEnd() else {
                throw WasmDecodeError.invalidWasmFile
            }
            return BinarySource(data: _data)
        } catch {
            throw WasmDecodeError.invalidWasmFile
        }
    }
}

private extension WasmDecoder {
    func decodeModule() throws -> Module {
        // Magic Number
        guard source.consume(4) == Module.magicNumber else {
            throw WasmDecodeError.maginNumberNotFound
        }
        
        // Version field
        guard let version = source.consume(4),
              version == Module.version else {
            throw WasmDecodeError.versionNotMatched
        }
        
        // Decode sections
        var typeSection: TypeSection?
        var importSection: ImportSection?
        var functionSection: FunctionSection?
        var tableSection: TableSection?
        var memorySection: MemorySection?
        var globalSection: GlobalSection?
        var exportSection: ExportSection?
        var startSection: StartSection?
        var elementSection: ElementSection?
        var codeSection: CodeSection?
        var dataSection: DataSection?
        var dataCountSection: DataCountSection?
        
        try decodeSections(typeSection: &typeSection,
                           importSection: &importSection,
                           functionSection: &functionSection,
                           tableSection: &tableSection,
                           memorySection: &memorySection,
                           globalSection: &globalSection,
                           exportSection: &exportSection,
                           startSection: &startSection,
                           elementSection: &elementSection,
                           codeSection: &codeSection,
                           dataSection: &dataSection,
                           dataCountSection: &dataCountSection)
        
        return Module(
            typeSection: typeSection,
            importSection: importSection,
            functionSection: functionSection,
            tableSection: tableSection,
            memorySection: memorySection,
            globalSection: globalSection,
            exportSection: exportSection,
            startSection: startSection,
            elementSection: elementSection,
            codeSection: codeSection,
            dataSection: dataSection,
            dataCountSection: dataCountSection
        )
    }
}

// MARK: - Decode Sections
private extension WasmDecoder {
    func decodeSections(typeSection: inout TypeSection?,
                        importSection: inout ImportSection?,
                        functionSection: inout FunctionSection?,
                        tableSection: inout TableSection?,
                        memorySection: inout MemorySection?,
                        globalSection: inout GlobalSection?,
                        exportSection: inout ExportSection?,
                        startSection: inout StartSection?,
                        elementSection: inout ElementSection?,
                        codeSection: inout CodeSection?,
                        dataSection: inout DataSection?,
                        dataCountSection: inout DataCountSection?) throws {
        while source.remaining > 0 {
            guard let sectionID = source.current,
                  let section = Section(rawValue: sectionID) else {
                throw WasmDecodeError.illegalSection
            }
            
//            print("decoding.. \(section)")
            
            switch section {
            case .custom:
                _ = try decodeCustomSection()
            case .type:
                typeSection = try decodeTypeSection()
//                print(typeSection ?? "")
            case .import:
                importSection = try decodeImportSection()
//                print(importSection ?? "")
            case .function:
                functionSection = try decodeFunctionSection()
//                print(functionSection ?? "")
            case .table:
                tableSection = try decodeTableSection()
//                print(tableSection ?? "")
            case .memory:
                memorySection = try decodeMemorySection()
//                print(memorySection ?? "")
            case .global:
                globalSection = try decodeGlobalSection()
//                print(globalSection ?? "")
            case .export:
                exportSection = try decodeExportSection()
//                print(exportSection ?? "")
            case .start:
                startSection = try decodeStartSection()
            case .element:
                elementSection = try decodeElementSection()
            case .code:
                codeSection = try decodeCodeSection()
//                print(codeSection ?? "")
            case .data:
                dataSection = try decodeDataSection()
            case .dataCount:
                dataCountSection = try decodeDataCountSection()
            }
        }
    }
    
    // TODO: Decode the section
    func decodeCustomSection() throws -> CustomSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalCustomSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalCustomSection
        }
        
//        print("size \(size)")
//        print("current \(source.currentIndex)")
        
        /*
        
        let nameVector: Vector<Character> = try decodeVector {
            guard let char = source.consume() else {
                throw WasmDecodeError.illegalExport
            }
            return char
        }
        
        guard let name = String(data: Data(nameVector.elements), encoding: .utf8) else {
            throw WasmDecodeError.illegalExport
        }
         */
        
        source.consume(Int(size))
        let name = "temporary"

//        print("current \(source.currentIndex)")
        
        return CustomSection(sectionID: sectionID,
                             size: size,
                             name: name)
    }
    
    func decodeTypeSection() throws -> TypeSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalTypeSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalTypeSection
        }
        
        let funcTypes: Vector<FunctionType> = try decodeVector {
            return try decodeFuncType()
        }
        
        return TypeSection(sectionID: sectionID,
                           size: size,
                           functionTypes: funcTypes)
    }
    
    func decodeImportSection() throws -> ImportSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalImportSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalImportSection
        }
        
        let imports: Vector<ImportSection.Import> = try decodeVector {
            let moduleVector: Vector<UInt8> = try decodeVector {
                guard let char = source.consume() else {
                    throw WasmDecodeError.illegalImportSection
                }
                return char
            }
            guard let module = String(data: Data(moduleVector.elements), encoding: .utf8) else {
                throw WasmDecodeError.illegalImportSection
            }

            let nameVector: Vector<UInt8> = try decodeVector {
                guard let char = source.consume() else {
                    throw WasmDecodeError.illegalImportSection
                }
                return char
            }
            guard let name = String(data: Data(nameVector.elements), encoding: .utf8) else {
                throw WasmDecodeError.illegalImportSection
            }
            
            guard let descriptorTypeValue = source.consume(),
                  let ImportDescriptorType = ImportSection.ImportDescriptorType(rawValue: descriptorTypeValue) else {
                throw WasmDecodeError.illegalImportSection
            }
            
            let descriptor: ImportSection.ImportDescriptor
            switch ImportDescriptorType {
            case .function:
                guard let typeIndex = source.consumeU32() else {
                    throw WasmDecodeError.illegalImportSection
                }
                descriptor = .function(typeIndex)
            case .memory:
                let memoryType = try decodeMemoryType()
                descriptor = .memory(memoryType)
            case .global:
                let globalType = try decodeGlobalType()
                descriptor = .global(globalType)
            }
            
            return ImportSection.Import(module: module,
                                        name: name,
                                        descriptor: descriptor)
        }
        
        return .init(sectionID: sectionID,
                     size: size,
                     imports: imports)
    }
    
    func decodeFunctionSection() throws -> FunctionSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalFuncSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalFuncSection
        }
        
        let indices: Vector<TypeIndex> = try decodeVector {
            guard let index = source.consumeU32() else {
                throw WasmDecodeError.illegalFuncSection
            }
            return index
        }
        
        return FunctionSection(sectionID: sectionID,
                           size: size,
                           indices: indices)
    }
    
    func decodeTableSection() throws -> TableSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalTableSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalTableSection
        }
        
        let tableTypes: Vector<TableType> = try decodeVector {
            guard let byte = source.consume(),
                  let referenceType = ReferenceType(rawValue: byte) else {
                throw WasmDecodeError.illegalTableSection
            }
            do {
                let limits = try decodeLimits()
                return TableType(referenceType: referenceType,
                                 limits: limits)
            } catch {
                throw WasmDecodeError.illegalTableSection
            }
        }
        
        return TableSection(sectionID: sectionID,
                             size: size,
                             tableTypes: tableTypes)
    }
    
    func decodeMemorySection() throws -> MemorySection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalMemorySection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalMemorySection
        }
        
        let memoryTypes: Vector<MemoryType> = try decodeVector {
            return try decodeMemoryType()
        }
        
        return MemorySection(sectionID: sectionID,
                             size: size,
                             memoryTypes: memoryTypes)
    }
    
    func decodeGlobalSection() throws -> GlobalSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalGlobalSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalGlobalSection
        }
        
        let globals: Vector<GlobalSection.Global> = try decodeVector {
            try decodeGlobal()
        }

        return GlobalSection(sectionID: sectionID,
                             size: size,
                             globals: globals)
    }
    
    func decodeGlobal() throws -> GlobalSection.Global {
        let globalType = try decodeGlobalType()
        
        let expression: Expression
        do {
            expression = try decodeExpression()
        } catch {
            throw WasmDecodeError.illegalGlobal
        }
        
        return GlobalSection.Global(type: globalType,
                                    expression: expression)
    }
    
    func decodeLimits() throws -> Limits {
        guard let limitsTypeValue = source.consume(),
              let limitsType = Limits.LimitsType(rawValue: limitsTypeValue) else {
            throw WasmDecodeError.illegalMemoryType
        }
        
        switch limitsType {
        case .min:
            guard let n = source.consumeU32() else {
                throw WasmDecodeError.illegalMemoryType
            }
            return .min(n: n)
        case .minMax:
            guard let n = source.consumeU32() else {
                throw WasmDecodeError.illegalMemoryType
            }
            guard let m = source.consumeU32() else {
                throw WasmDecodeError.illegalMemoryType
            }
            return .minMax(n: n, m: m)
        }
    }

    func decodeMemoryType() throws -> MemoryType {
        return try decodeLimits()
    }

    func decodeGlobalType() throws -> GlobalType {
        let valueType: ValueType
        do {
            valueType = try decodeValueType()
        } catch {
            throw WasmDecodeError.illegalGlobalType
        }
        guard let typeValue = source.consume(),
              let mutability = GlobalType.Mutability(rawValue: typeValue) else {
            throw WasmDecodeError.illegalGlobalType
        }
        return .init(valueType: valueType,
                     mutability: mutability)
    }
    
    func decodeExportSection() throws -> ExportSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalExportSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalExportSection
        }
        
        let exports: Vector<ExportSection.Export> = try decodeVector {
            try decodeExport()
        }

        return ExportSection(sectionID: sectionID,
                             size: size,
                             exports: exports)
    }
    
    func decodeExport() throws -> ExportSection.Export {
        let nameVector: Vector<UInt8> = try decodeVector {
            guard let char = source.consume() else {
                throw WasmDecodeError.illegalExport
            }
            return char
        }
        
        guard let name = String(data: Data(nameVector.elements), encoding: .utf8) else {
            throw WasmDecodeError.illegalExport
        }
        
        guard let descriptorTypeValue = source.consume(),
              let descriptorType = ExportSection.ExportDescriptorType(rawValue: descriptorTypeValue) else {
            throw WasmDecodeError.illegalExport
        }
        
        let descriptor: ExportSection.ExportDescriptor
        switch descriptorType {
        case .functionIndex:
            guard let index = source.consumeU32() else {
                throw WasmDecodeError.illegalExport
            }
            descriptor = .function(index)
        case .tableIndex:
            guard let index = source.consumeU32() else {
                throw WasmDecodeError.illegalExport
            }
            descriptor = .table(index)
        case .memoryIndex:
            guard let index = source.consumeU32() else {
                throw WasmDecodeError.illegalExport
            }
            descriptor = .memory(index)
        case .globalIndex:
            guard let index = source.consumeU32() else {
                throw WasmDecodeError.illegalExport
            }
            descriptor = .global(index)
        }
        
        let export = ExportSection.Export(name: name, descriptor: descriptor)
        return export
    }
    
    func decodeStartSection() throws -> StartSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalStartSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalStartSection
        }
        
        guard let functionIndex = source.consumeU32() else {
            throw WasmDecodeError.illegalCodeSection
        }

        return StartSection(sectionID: sectionID,
                            size: size,
                            start: functionIndex)
    }

    func decodeElementSection() throws -> ElementSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalElementSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalElementSection
        }
        
        let elements: Vector<ElementSection.Element> = try decodeVector {
            do {
                return try decodeElement()
            } catch {
                throw WasmDecodeError.illegalElementSection
            }
        }
        
        return ElementSection(sectionID: sectionID,
                              size: size,
                              elements: elements)
    }

    func decodeElement() throws -> ElementSection.Element {
        guard let index = source.consumeU32() else {
            throw WasmDecodeError.illegalElement
        }
        
        let expression: Expression
        do {
            expression = try decodeExpression()
        } catch {
            throw WasmDecodeError.illegalElement
        }
        
        let indices: Vector<FunctionIndex> = try decodeVector {
            guard let index = source.consumeU32() else {
                throw WasmDecodeError.illegalCodeSection
            }
            return index
        }
        
        return ElementSection.Element(index: index,
                                      expression: expression,
                                      indices: indices)
    }

    func decodeCodeSection() throws -> CodeSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalCodeSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalCodeSection
        }
        
        let codes: Vector<CodeSection.Code> = try decodeVector {
            guard let size = source.consumeU32() else {
                throw WasmDecodeError.illegalCodeSection
            }
            
            let locals: Vector<[ValueType]> = try decodeVector {
                guard let n = source.consumeU32() else {
                    throw WasmDecodeError.illegalCodeSection
                }

                let valueType = try decodeValueType()
                return (0 ..< n).map { _ in valueType }

            }
            
            let expression = try decodeExpression()
            
            return CodeSection.Code(size: size,
                                    locals: locals.elements.flatMap { $0 },
                                    expression: expression)
        }
        
        return CodeSection(sectionID: sectionID,
                           size: size,
                           codes: codes)
    }
    
    func decodeDataSection() throws -> DataSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalDataSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalDataSection
        }
        
        let datas: Vector<DataSection.Data> = try decodeVector {
            guard let memoryIndex = source.consumeU32() else {
                throw WasmDecodeError.illegalDataSection
            }
            
            let expression = try decodeExpression()
            
            let initializer: Vector<Byte> = try decodeVector {
                guard let byte = source.consume() else {
                    throw WasmDecodeError.illegalDataSection
                }
                
                return byte
            }
            
            return DataSection.Data(memoryIndex: memoryIndex,
                                    expression: expression,
                                    initializer: initializer)
        }
        
        return DataSection(sectionID: sectionID,
                           size: size,
                           datas: datas)
    }
    
    func decodeDataCountSection() throws -> DataCountSection {
        guard let sectionID = source.consume() else {
            throw WasmDecodeError.illegalDataCountSection
        }
        
        guard let size = source.consumeU32() else {
            throw WasmDecodeError.illegalDataCountSection
        }
        
        guard let numberOfDataSegments = source.consumeU32() else {
            throw WasmDecodeError.illegalDataCountSection
        }
        
        return DataCountSection(sectionID: sectionID,
                                size: size,
                                numberOfDataSegments: numberOfDataSegments)
    }
    
    func decodeExpression() throws -> Expression {
        var instructions: [Instruction] = []
        var block = 0

        while true {
            // TODO: Implement decodeInstruction method
            guard let byte = source.consume() else {
                throw WasmDecodeError.illegalExpression
                
            }
            guard let instructionID = Instruction.ID(rawValue: byte) else {
                print("Not supported instruction: \(byte.hex)")
                throw WasmDecodeError.illegalExpression
            }
            
//            print("instructionID=\(instructionID)")
            
            let instruction: Instruction
            switch instructionID {
            // Control InstructionsI
            case .unreachable:
                instruction = .unreachable
            case .nop:
                instruction = .nop
            case .block:
                let blockType = try decodeBlockType()
                instruction = .block(blockType)
            case .loop:
                let blockType = try decodeBlockType()
                instruction = .loop(blockType)
            case .if:
                let blockType = try decodeBlockType()
                instruction = .if(blockType)
            case .else:
                instruction = .else
            case .br:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .br(index)
            case .brIf:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .brIf(index)
            case .return:
                instruction = .return
            case .call:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .call(index)
                
            // Variable Instructions
            case .localGet:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .localGet(index)
            case .localSet:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .localSet(index)
            case .localTee:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .localTee(index)
            case .globalGet:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .globalGet(index)
            case .globalSet:
                guard let index = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .globalSet(index)
            case .f32Add:
                instruction = .f32Add
            case .f64Add:
                instruction = .f64Add

            // Memory Instructions
            case .dataDrop:
                guard let const = source.consumeU32(),
                      const == 9 else {
                    throw WasmDecodeError.illegalExpression
                }
                guard let dataIndex = source.consumeU32() else {
                    throw WasmDecodeError.illegalExpression
                }
                
                instruction = .dataDrop(dataIndex)
                
            // Numeric Instruction
            case .i32Const:
                guard let value = source.consumeI32() else {
                    throw WasmDecodeError.illegalExpression
                }
                instruction = .i32Const(value)
            case .i64Const:
                instruction = .end // Temporary
            case .f32Const:
                instruction = .end // Temporary
            case .f64Const:
                instruction = .end // Temporary
                
            case .i32Eq:
                instruction = .i32Eq
            case .i32GeU:
                instruction = .i32GeU
                
            case .i32Add:
                instruction = .i32Add
            case .i32Sub:
                instruction = .i32Sub
            case .i32Mul:
                instruction = .i32Mul
            case .i32RemU:
                instruction = .i32RemU
            case .i64Add:
                instruction = .i64Add
            // Expressions
            case .end:
                instruction = .end
                if block == 0 {
                    instructions.append(instruction)
                    return Expression(instructions: instructions)
                } else {
                    block -= 1
                }
            }
            instructions.append(instruction)
            if instruction.isBlock {
                block += 1
            }
        }
    }
}

// MARK: - Decode Vector
private extension WasmDecoder {
    func decodeVector<T>(consumeElement: () throws -> T) throws -> Vector<T> {
        guard let length = source.consumeU32() else {
            throw WasmDecodeError.illegalVector
        }
        
        var elements: [T] = []
        while elements.count < length {
            let element: T = try consumeElement()
            elements.append(element)
        }
        
        return Vector(length: length,
                      elements: elements)
    }
}
 
// MARK: - Decode Types
private extension WasmDecoder {
    func decodeFuncType() throws -> FunctionType {
        guard let prefix = source.consume(),
              prefix == FunctionType.id else {
            throw WasmDecodeError.illegalFunctionType
        }

        let resultType1 = try decodeResultType()
        let resultType2 = try decodeResultType()

        return FunctionType(parameterTypes: resultType1,
                            resultTypes: resultType2)
    }
    
    func decodeResultType() throws -> ResultType {
        let valueTypes: Vector<ValueType> = try decodeVector {
            return try decodeValueType()
        }

        return ResultType(valueTypes: valueTypes)
    }
    
    func decodeBlockType() throws -> BlockType {
        guard let value = source.consume() else {
            throw WasmDecodeError.illegalBlockType
        }

        if value == BlockType.emptyByte {
            return .empty
        }
        
        if let valueType = ValueType.from(byte: value) {
            return .value(valueType)
        }

        throw WasmDecodeError.illegalBlockType
    }
    
    func decodeValueType() throws -> ValueType {
        guard let value = source.consume() else {
            throw WasmDecodeError.illegalValueType
        }
        
        if let valueType = ValueType.from(byte: value) {
            return valueType
        }

        throw WasmDecodeError.illegalValueType
    }
}
