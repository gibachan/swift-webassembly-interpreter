//
//  Vector.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/13.
//

import Foundation
import SwiftLEB128

struct Vector<T> {
    let length: U32
    let elements: [T]
}

extension Vector: Equatable where T: Equatable {}
