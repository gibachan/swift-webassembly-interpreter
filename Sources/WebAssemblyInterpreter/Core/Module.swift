//
//  Module.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/10.
//

import Foundation

// https://webassembly.github.io/spec/core/binary/modules.html
public struct Module {
    static let magicNumber: Data = Data([0x00, 0x61, 0x73, 0x6D]) // "\0asm"
    static let version: Data = Data([0x01, 0x00, 0x00, 0x0])
    
    let typeSection: TypeSection?
    let importSection: ImportSection?
    let functionSection: FunctionSection?
    let tableSection: TableSection?
    let memorySection: MemorySection?
    let globalSection: GlobalSection?
    let exportSection: ExportSection?
    let startSection: StartSection?
    let elementSection: ElementSection?
    let codeSection: CodeSection?
    let dataSection: DataSection?
    let dataCountSection: DataCountSection?
}

extension Module {
    // https://webassembly.github.io/spec/core/binary/modules.html#export-section
    enum ExportDesc: Byte {
        case funcidx = 0x00
        case tableidx = 0x01
        case memidx = 0x02
        case globalidx = 0x03
    }
}

// https://webassembly.github.io/spec/core/syntax/modules.html#modules
extension Module {
    // TODO: Implement tables, elements, start

    var types: [FunctionType] {
        typeSection?.functionTypes.elements.map { $0 } ?? []
    }
    
    var functions: [Function] {
        let typeIndices = functionSection?.indices.elements.map { $0 } ?? []
        let codes = codeSection?.codes.elements.map { $0 } ?? []
        guard typeIndices.count == codes.count else {
            fatalError("Type index count should match with code count")
        }
        
        let functions = codes.enumerated().map { index, code in
            Function(index: typeIndices[index],
                     locals: code.locals.elements.flatMap { $0 },
                     body: code.expression)
        }
        
        return functions
    }
    
    var memories: [MemoryType] {
        memorySection?.memoryTypes.elements.map { $0 } ?? []
    }
    
    var globals: [GlobalSection.Global] {
        globalSection?.globals.elements.map { $0 } ?? []
    }
    
    var datas: [DataSection.Data] {
        dataSection?.datas.elements.map { $0 } ?? []
    }
    
    var imports: [ImportSection.Import] {
        importSection?.imports.elements.map { $0 } ?? []
    }
    
    var exports: [ExportSection.Export] {
        exportSection?.exports.elements.map { $0 } ?? []
    }
}
