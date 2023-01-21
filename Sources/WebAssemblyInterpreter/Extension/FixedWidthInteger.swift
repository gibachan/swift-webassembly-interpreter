//
//  FixedWidthInteger.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/01/21.
//

import Foundation

extension FixedWidthInteger {
    var shiftMask: Self {
        self & Self(Self.bitWidth - 1)
    }
}
