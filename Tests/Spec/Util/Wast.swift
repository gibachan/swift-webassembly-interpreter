//
//  Wast.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/01/12.
//

import Foundation
@testable import WebAssemblyInterpreter

struct Wast: Decodable {
    let sourceFilename: String
    let commands: [Command]

    private enum CodingKeys: String, CodingKey {
        case sourceFilename = "source_filename"
        case commands
    }
}

extension Wast {
    struct Command: Decodable {
        let type: CommandType
        let line: Int
        let filename: String?
        let action: Action?
        let expected: [Variable]?
    }

    enum CommandType: String, Decodable {
        case module
        case assertReturn = "assert_return"
        case assertMalformed = "assert_malformed"
        case assertTrap = "assert_trap"
        case assertInvalid = "assert_invalid"
    }

    struct Action: Decodable {
        let type: String
        let field: String
        let args: [Variable]
    }

    struct Variable: Decodable {
        let type: VariableType
        let value: String?
    }

    enum VariableType: String, Decodable {
        case i32
        case f32
        case f64
    }
}

extension Wast.Variable {
    var i32: I32 {
        switch type {
        case .i32:
            guard let value,
                  let intValue = Int(value) else {
                fatalError()
            }
            return I32(intValue % Int(Int32.max)) // TODO: Merge into app code
        default:
            fatalError()
        }
    }
}
