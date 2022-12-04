import Foundation
import WebAssemblyInterpreter

@main
public struct Demo {
    public static func main() {
        guard CommandLine.arguments.count == 2 else {
            print("File path is not specified.")
            return
        }

        let filePath = CommandLine.arguments[1]
        do {
            let decoder = try WasmDecoder(filePath: filePath)
            let wasm = try decoder.invoke()
            
            let runtime = Runtime()
            var result: Value?
            let moduleInstance = runtime.instanciate(module: wasm.module)
            try runtime.invoke(moduleInstance: moduleInstance,
                               functionName: "my_func", arguments: [Value.i32(10)], result: &result)
            
            print("[Succeeded] fib result: \(result)")
        } catch {
            print("Failed to parse wasm: \(filePath)")
            print("\(error) : \(error.localizedDescription)")
        }
    }
}
