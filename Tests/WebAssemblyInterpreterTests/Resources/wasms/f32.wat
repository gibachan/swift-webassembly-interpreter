(module
    (func (export "f32_eq_test") (param f32 f32) (result i32)
        local.get 0
        local.get 1
        f32.eq
    )
    (func (export "f32_ne_test") (param f32 f32) (result i32)
        local.get 0
        local.get 1
        f32.ne
    )
    (func (export "f32_lt_test") (param f32 f32) (result i32)
        local.get 0
        local.get 1
        f32.lt
    )
    (func (export "f32_gt_test") (param f32 f32) (result i32)
        local.get 0
        local.get 1
        f32.gt
    )
    (func (export "f32_le_test") (param f32 f32) (result i32)
        local.get 0
        local.get 1
        f32.le
    )
    (func (export "f32_ge_test") (param f32 f32) (result i32)
        local.get 0
        local.get 1
        f32.ge
    )
)
