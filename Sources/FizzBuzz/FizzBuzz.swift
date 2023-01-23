//
//  FizzBuzz.swift
//  
//
//  Created by Tatsuyuki Kobayashi on 2022/12/17.
//

import Foundation
import WebAssemblyInterpreter

@main
public struct FizzBuzz {
    public static func main() {
        guard CommandLine.arguments.count == 2 else {
            print("File path is not specified.")
            return
        }

        guard let inputValue = Int(CommandLine.arguments[1]) else {
            print("Input value is not specified.")
            return
        }
        
        let filePath = "./Tests/WebAssemblyInterpreterTests/Resources/wasms/fizzbuzz.wasm"
        do {
            let decoder = try WasmDecoder(filePath: filePath)
            let wasm = try decoder.invoke()
            
            let runtime = Runtime()
            var result: Value?
            let hostEnvironment = HostEnvironment()
            hostEnvironment.addCode(name: "print_value") { arguments in
                switch arguments.first {
                case let .i32(value):
                    print(value)
                default:
                    fatalError()
                }
                return []
            }
            hostEnvironment.addCode(name: "print_string") { arguments in
                let values = arguments.compactMap { argument in
                    switch argument {
                    case let .i32(value):
                        return value
                    default:
                        return nil
                    }
                }
                guard values.count == 2 else {
                    fatalError("Unexpected error")
                }
                
                let stringData = hostEnvironment.memory.data[values[1]..<(values[1] + values[0])]
                guard let string = String(data: stringData, encoding: .utf8) else {
                    fatalError("Unexpected error")
                }
                print(string)
                return []
            }
            let moduleInstance = runtime.instanciate(module: wasm.module, hostEnvironment: hostEnvironment)
            try runtime.invoke(moduleInstance: moduleInstance,
                               functionName: "fizzbuzz", arguments: [.init(i32: inputValue)], result: &result)
        } catch {
            print("Failed to parse wasm: \(filePath)")
        }
    }
}

