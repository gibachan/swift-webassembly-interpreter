//
//  StringExtension.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/11/13.
//

import Foundation

extension String {
    // FIXME: This works?
    func encode() -> [Byte] {
        var bytes: [Byte] = [Byte(count)]
        
        let cstr:[CChar] = self.cString(using: .ascii)!
        for cchar in cstr {
            if cchar == CChar(0) {
                break
            }

            bytes.append(UInt8(cchar))
        }
        
        return bytes
    }
}
