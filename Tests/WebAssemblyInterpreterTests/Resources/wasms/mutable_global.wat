(module
    (global $value (mut i32) (i32.const 0)) 
    (func (export "increment_global")
        (result i32)

        (global.set $value 
            (i32.add (global.get $value) (i32.const 1)) ;; value++
        )

        (global.get $value)
    )
)
