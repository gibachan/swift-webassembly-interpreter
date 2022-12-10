//
//  Label.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/01.
//

import Foundation

struct Label {
    let id = UUID().uuidString // for debug purpose
    let blockType: BlockType
    let block: Function.Block
}

extension Label {
    var arity: Int { blockType.arity }
}
