import Foundation
import WebAssemblyInterpreter

@main
public struct Demo {
    public static func main() {
        guard CommandLine.arguments.count == 3 else {
            print("File path is not specified.")
            return
        }

        let filePath = CommandLine.arguments[1]
        guard let inputValue = Int32(CommandLine.arguments[2]) else {
            print("Input value is not specified.")
            return
        }
        
        do {
            let decoder = try WasmDecoder(filePath: filePath)
            let wasm = try decoder.invoke()
            
            let runtime = Runtime()
            var result: Value?
            let moduleInstance = runtime.instanciate(module: wasm.module)
            try runtime.invoke(moduleInstance: moduleInstance,
                               functionName: "is_prime", arguments: [.i32(inputValue)], result: &result)
            switch result {
            case let .some(.i32(result)):
                if result == 0 {
                    print("\(inputValue) is not a prime number.")
                } else {
                    print("\(inputValue) is a prime number.")
                }
            default:
                print("Unexpected error occured.")
            }
        } catch {
            print("Failed to parse wasm: \(filePath)")
            print("\(error) : \(error.localizedDescription)")
        }
    }
}
