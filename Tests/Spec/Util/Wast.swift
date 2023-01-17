//
//  Wast.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2023/01/12.
//

import Foundation

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
        let expected: [Variable]?
    }

    struct Variable: Decodable {
        let type: String
        let value: String
    }
}
