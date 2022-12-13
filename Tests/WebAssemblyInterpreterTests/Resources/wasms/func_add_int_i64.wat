(module
    (func (export "AddInt")
        (param $value_1 i64) (param $value_2 i64)
        (result i64)
        local.get $value_1
        local.get $value_2
        i64.add
    )
)
