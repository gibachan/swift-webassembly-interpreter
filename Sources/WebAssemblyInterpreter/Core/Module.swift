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
    let startSection: StartSection?
    let codeSection: CodeSection?
    let dataSection: DataSection?
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
