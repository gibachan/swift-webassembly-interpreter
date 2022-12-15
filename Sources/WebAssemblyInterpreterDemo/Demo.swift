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
            let hostCode: HostCode? = { arguments in
                guard let argument = arguments.first else { fatalError() }
                if case let .i32(value) = argument {
                    print("Hello World")
                    return [.i32(value + 1)]
                } else {
                    fatalError()
                }
            }
            let moduleInstance = runtime.instanciate(module: wasm.module,
                                                     hostCode: hostCode)
            try runtime.invoke(moduleInstance: moduleInstance,
                               functionName: "CallImportedFunction", arguments: [], result: &result)
            
            print("[Succeeded] result: \(result.debugDescription)")
        } catch {
            print("Failed to parse wasm: \(filePath)")
            print("\(error) : \(error.localizedDescription)")
        }
    }
}
