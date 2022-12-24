//
//  WasmDecodeError.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/20.
//

import Foundation

public enum WasmDecodeError: Error {
    // Wasm
    case fileNotFound
    case invalidWasmFile
    case moduleNotFound
    
    // Module
    case maginNumberNotFound
    case versionNotMatched
    case illegalSection
    
    // Section
    case illegalCustomSection
    case illegalTypeSection
    case illegalImportSection
    case illegalFuncSection
    case illegalTableSection
    case illegalMemorySection
    case illegalGlobalSection
    case illegalExportSection
    case illegalStartSection
    case illegalElementSection
    case illegalCodeSection
    case illegalDataSection
    case illegalDataCountSection
    
    // Type
    case illegalFunctionType
    case illegalBlockType
    case illegalValueType
    case illegalMemoryType
    
    // Global
    case illegalGlobal
    case illegalGlobalType
    
    // Export
    case illegalExport
    
    // Vector
    case illegalVector
    
    // Expression
    case illegalExpression
    
    // Element
    case illegalElement
}
