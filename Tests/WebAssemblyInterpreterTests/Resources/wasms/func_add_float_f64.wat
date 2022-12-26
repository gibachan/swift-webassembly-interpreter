(module
    (func (export "AddFloat64")
        (param $value_1 f64) (param $value_2 f64)
        (result f64)
        local.get $value_1
        local.get $value_2
        f64.add    
    )
)