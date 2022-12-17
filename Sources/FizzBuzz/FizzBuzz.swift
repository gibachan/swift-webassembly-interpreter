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

        guard let inputValue = Int32(CommandLine.arguments[1]) else {
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
            hostEnvironment.addCode(name: "print_fizz") { _ in
                print("Fizz")
                return []
            }
            hostEnvironment.addCode(name: "print_buzz") { _ in
                print("Buzz")
                return []
            }
            hostEnvironment.addCode(name: "print_fizzbuzz") { _ in
                print("FizzBuzz")
                return []
            }
            let moduleInstance = runtime.instanciate(module: wasm.module, hostEnvironment: hostEnvironment)
            try runtime.invoke(moduleInstance: moduleInstance,
                               functionName: "fizzbuzz", arguments: [.i32(inputValue)], result: &result)
        } catch {
            print("Failed to parse wasm: \(filePath)")
        }
    }
}

