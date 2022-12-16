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
            let hostEnvironment = HostEnvironment()
            hostEnvironment.addCode(name: "print_string") { arguments in
                print("print_string result=\(hostEnvironment.memory.data)")
                return []
            }
            hostEnvironment.addGlobal(name: "start_string", value: .i32(0))
            let moduleInstance = runtime.instanciate(module: wasm.module,
                                                     hostEnvironment: hostEnvironment)
            try runtime.invoke(moduleInstance: moduleInstance,
                               functionName: "helloworld", arguments: [], result: &result)
            
            print("[Succeeded] result: \(result.debugDescription)")
        } catch {
            print("Failed to parse wasm: \(filePath)")
            print("\(error) : \(error.localizedDescription)")
        }
    }
}
