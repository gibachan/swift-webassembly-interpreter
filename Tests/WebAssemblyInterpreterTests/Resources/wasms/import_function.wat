(module
    (import "env" "imported_func" (func $my_func(param i32)))
    (func (export "my_func")
        (call $my_func (i32.const 1))
    )
)