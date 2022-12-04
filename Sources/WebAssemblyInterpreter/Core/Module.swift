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
    let globalSection: GlobalSection?
    let exportSection: ExportSection?
    let codeSection: CodeSection?
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

extension Module {
    func findExportedFunction(withName name: String) -> (type: FunctionType, code: CodeSection.Code)? {
        guard let exportSection = exportSection,
              let export = exportSection.exports.elements.first(where: { $0.name == name }) else {
            return nil
        }
        
        let functionIndex: FunctionIndex
        switch export.descriptor {
        case let .function(index):
            functionIndex = index
        case .table, .memory, .global:
            return nil
        }
        
        guard let typeSection = typeSection,
              functionIndex <= typeSection.functionTypes.length - 1 else {
            return nil
        }
        
        let functionTable = zip(functionSection?.indices.elements ?? [], codeSection?.codes.elements ?? [])
            .map { functionIndex, code in
                return (functionIndex, code)
            }

        guard let code = functionTable.first(where: { $0.0 == functionIndex })?.1 else {
            return nil
        }
        
        return (type: typeSection.functionTypes.elements[Int(functionIndex)], code: code)
    }
}
