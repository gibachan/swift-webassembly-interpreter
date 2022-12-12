//
//  Function.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import Foundation

// https://webassembly.github.io/spec/core/syntax/modules.html#functions
struct Function {
    let type: FunctionType
    let index: TypeIndex
    let locals: [ValueType]
    let body: Expression
}

extension Function {
    struct Block {
        let instruction: Instruction
        let arity: BlockType
        var startIndex: Int
        var endIndex: Int?
    }
    
    // Should be stroed variable
    var blocks: [Int: Block] {
        var blocks: [Int: Block] = [:] // key: startIndex
        var blockStack: [Block] = []
        
        let resultBlockType: BlockType
        if let resultType = type.resultTypes.valueTypes.elements.first {
            resultBlockType = .value(resultType)
        } else {
            resultBlockType = .empty
        }
        
        blockStack.append(.init(instruction: .end,
                                arity: resultBlockType,
                                startIndex: 0,
                                endIndex: nil))
        
        for i in 0..<body.instructions.count {
            let instruction = body.instructions[i]
            let blockType: BlockType?
            
            switch instruction {
            case .block(let _blockType), .loop(let _blockType), .if(let _blockType):
                blockType = _blockType
            case .end:
                blockType = .empty
            default:
                blockType = nil
            }
            
            guard let blockType else { continue }
            
            if instruction.isEnd {
                if var block = blockStack.popLast() {
                    block.endIndex = i
                    
                    // update block
                    blocks[block.startIndex] = block
                }
            } else {
                let block = Block(instruction: instruction,
                                  arity: blockType,
                                  startIndex: i,
                                  endIndex: nil)
                blockStack.append(block)
            }
        }

        return blocks
    }
}

private extension Instruction {
    var isEnd: Bool {
        switch self {
        case .end:
            return true
        default:
            return false
        }
    }
}
