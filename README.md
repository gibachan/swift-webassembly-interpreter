# swift-webassembly-interpreter

A toy WebAssembly interpreter written in Swift. This project is intended to learn [WebAssembly spec](https://webassembly.github.io/spec/core/) and just having fun with wasm.

## Usage

For examle, it can execute Fizz Buzz logic described in wasm as below.
```
% swift run FizzBuzz 16
Building for debugging...
[3/3] Linking FizzBuzz
Build complete! (0.35s)
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
```

For more detail can be found in [test cases](https://github.com/gibachan/swift-webassembly-interpreter/blob/main/Tests/WebAssemblyInterpreterTests/Execution/RuntimeTests.swift).
