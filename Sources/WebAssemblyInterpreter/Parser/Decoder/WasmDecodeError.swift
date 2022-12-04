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
    case illegalGlobalSection
    case illegalExportSection
    case illegalCodeSection
    
    // Type
    case illegalFunctionType
    case illegalBlockType
    case illegalValueType
    
    // Global
    case illegalGlobal
    case illegalGlobalType
    
    // Export
    case illegalExport
    
    // Vector
    case illegalVector
    
    // Expression
    case illegalExpression
}
