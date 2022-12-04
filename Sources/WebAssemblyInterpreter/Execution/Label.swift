//
//  Label.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import Foundation

struct Label {
    let id = UUID().uuidString
    let blockType: BlockType
    let block: Function.Block
}

extension Label {
    var arity: ValueType? {
        switch blockType {
        case .empty:
            return nil
        case let .value(valueType):
            return valueType
        }
    }
}
