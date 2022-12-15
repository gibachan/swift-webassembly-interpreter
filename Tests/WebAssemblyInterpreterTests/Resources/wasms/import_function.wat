(module
  (import "env" "increment"
    (func $increment
      (param $value_1 i32)
      (result i32)
    )
  )
  (func (export "CallImportedFunction")
    (result i32)

    i32.const 12
    (call $increment)
  )
)
