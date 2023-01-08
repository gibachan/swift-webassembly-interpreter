(module
  (global $i (mut i32) (i32.const 0))
  (table 2 funcref)
  (elem (i32.const 0) $increment_global $square)
  (func $increment_global (result i32)
    (global.set $i
      (i32.add (global.get $i) (i32.const 1))
    ) ;; i++
    global.get $i
  )
  (func $square (param $value i32) (result i32)
    local.get $value
    local.get $value
    i32.mul   
  )
  (type $increment_global_type (func (result i32)))
  (type $square_type (func (param i32) (result i32)))
  
  (func (export "TestIncrementGlobal") (result i32)
    (i32.const 0)
    call_indirect (type $increment_global_type)
  )
  (func (export "TestSquare") (param $value i32) (result i32)
    local.get $value
    (i32.const 1)
    call_indirect (type $square_type)
  )
)
