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
    let startIndex: Int
    let endIndex: Int?
    let isLoop: Bool
}

extension Label {
    var arity: Int { blockType.arity }
}
