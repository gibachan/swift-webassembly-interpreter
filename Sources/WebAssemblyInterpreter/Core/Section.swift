//
//  Section.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/19.
//

import Foundation

// https://webassembly.github.io/spec/core/binary/modules.html#sections
enum Section: Byte {
    case custom = 0
    case type = 1
    case `import` = 2
    case function = 3
    case table = 4
    case memory = 5
    case global = 6
    case export = 7
    case start = 8
    case element = 9
    case code = 10
    case data = 11
    case dataCount = 12
}

// https://webassembly.github.io/spec/core/binary/modules.html#custom-section
struct CustomSection {
    let sectionID: Byte
    let size: U32
    let name: String
}

// https://webassembly.github.io/spec/core/binary/modules.html#type-section
struct TypeSection {
    let sectionID: Byte
    let size: U32
    let functionTypes: Vector<FunctionType>
}

extension TypeSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Type Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Function type count: \(functionTypes.length)",
            functionTypes.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#import-section
struct ImportSection {
    let sectionID: Byte
    let size: U32
    let imports: Vector<Import>
}

extension ImportSection {
    struct Import {
        let module: String
        let name: String
        let descriptor: ImportDescriptor
    }
    
    enum ImportDescriptorType: Byte {
        // TODO: table, memory
        case function = 0x00
//        case table = 0x01
        case memory = 0x02
        case global = 0x03
    }

    enum ImportDescriptor {
        // TODO: table, memory
        case function(TypeIndex)
        case memory(MemoryType)
        case global(GlobalType)
        
        var type: ImportDescriptorType {
            switch self {
            case .function: return .function
            case .memory: return .memory
            case .global: return .global
            }
        }
    }
}

extension ImportSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Import Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Import count: \(imports.length)",
            imports.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

extension ImportSection.Import: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Import] Module: \(module)",
            "Name: \(name)",
            "Descriptor: \(descriptor)"
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#function-section
struct FunctionSection {
    let sectionID: Byte
    let size: U32
    let indices: Vector<TypeIndex>
}

extension FunctionSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Function Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "TypeIndex count: \(indices.length)",
            indices.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#table-section
struct TableSection {
    let sectionID: Byte
    let size: U32
    let tableTypes: Vector<TableType>
}

extension TableSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Teble Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "TableType count: \(tableTypes.length)",
            tableTypes.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#binary-memsec
struct MemorySection {
    let sectionID: Byte
    let size: U32
    let memoryTypes: Vector<MemoryType>
}

extension MemorySection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Memory Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "MemoryType count: \(memoryTypes.length)",
            memoryTypes.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#global-section
struct GlobalSection {
    let sectionID: Byte
    let size: U32
    let globals: Vector<Global>
    
    struct Global {
        let type: GlobalType
        let expression: Expression
    }
}

extension GlobalSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Global Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Global count: \(globals.length)",
            globals.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

extension GlobalSection.Global: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Global] type: \(type)",
            "expression: \(expression)"
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#export-section
struct ExportSection {
    let sectionID: Byte
    let size: U32
    let exports: Vector<Export>
    
    // https://webassembly.github.io/spec/core/syntax/modules.html#syntax-export
    struct Export {
        let name: String
        let descriptor: ExportDescriptor
    }
    
    // https://webassembly.github.io/spec/core/binary/modules.html#binary-exportdesc
    enum ExportDescriptorType: Byte {
        case functionIndex = 0x00
        case tableIndex = 0x01
        case memoryIndex = 0x02
        case globalIndex = 0x03
    }
    
    enum ExportDescriptor {
        case function(FunctionIndex)
        case table(TableIndex)
        case memory(MemoryIndex)
        case global(GlobalIndex)
    }
}

extension ExportSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Export Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Export count: \(exports.length)",
            exports.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

extension ExportSection.Export: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Export] name: \(name)",
            "descriptor: \(descriptor)"
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#start-section
struct StartSection {
    let sectionID: Byte
    let size: U32
    let start: FunctionIndex
}

// https://webassembly.github.io/spec/core/binary/modules.html#element-section
struct ElementSection {
    let sectionID: Byte
    let size: U32
    let elements: Vector<Element>
    
    // TODO: Support different types of Element
    struct Element {
        let index: U32
        let expression: Expression
        let indices: Vector<FunctionIndex>
    }
}

extension ElementSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Element Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Element count: \(elements.length)",
            elements.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

extension ElementSection.Element: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Element] Index: \(index)",
            "Index count: \(indices.length)",
            indices.elements
                .map { "\($0)" }
                .joined(separator: ", "),
            "\(expression)"
        ].joined(separator: ", ")
    }
}


// https://webassembly.github.io/spec/core/binary/modules.html#code-section
struct CodeSection {
    let sectionID: Byte
    let size: U32
    let codes: Vector<Code>
    
    struct Code {
        let size: U32
        let locals: [ValueType]
        let expression: Expression
    }
}

extension CodeSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Code Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Code count: \(codes.length)",
            codes.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

extension CodeSection.Code: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Code] Size: \(size)",
            "Local count: \(locals.count)",
            locals
                .map { "\($0)" }
                .joined(separator: ", "),
            "\(expression)"
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#data-section
struct DataSection {
    let sectionID: Byte
    let size: U32
    let datas: Vector<Data>
    
    struct Data {
        let memoryIndex: U32
        let expression: Expression
        let initializer: Vector<Byte>
    }
}

extension DataSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Data Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Data count: \(datas.length)",
            datas.elements
                .map { "\($0)" }
                .joined(separator: ", ")
        ].joined(separator: ", ")
    }
}

extension DataSection.Data: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Data] MemoryIndex: \(memoryIndex)",
            "Expression: \(expression)",
            "initializer count: \(initializer.length)",
            initializer.elements
                .map { "\($0.hex)" }
                .joined(separator: ", "),
            "\(expression)"
        ].joined(separator: ", ")
    }
}

// https://webassembly.github.io/spec/core/binary/modules.html#data-count-section
struct DataCountSection {
    let sectionID: Byte
    let size: U32
    let numberOfDataSegments: U32
}

extension DataCountSection: CustomDebugStringConvertible {
    var debugDescription: String {
        [
            "[Data Count Section] ID: \(sectionID.hex)",
            "Size: \(size)",
            "Number of data segments: \(numberOfDataSegments)"
        ].joined(separator: ", ")
    }
}

