//
//  UInt8Extension.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/10.
//

import Foundation

extension UInt8 {
    var binary: String {
        var binaryString = ""
        var internalNumber = self
        var counter = 0
        
        for _ in (1...self.bitWidth) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
            if counter % 4 == 0 {
                binaryString.insert(contentsOf: " ", at: binaryString.startIndex)
            }
        }
        
        return binaryString
    }
    var hex: String {
        String(format: "%02X", self)
    }
}
