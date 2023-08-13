(module
  (memory 1)
  (global $pointer i32 (i32.const 128))

  ;; (func $init
  (func (export "init")
    ;; Store i32 value at $pointer
    (i32.store
      (global.get $pointer)
        (i32.const 10)
    )
  )

  (func (export "load_and_store") (result i32)
    ;; Load i32 value at $pointer
    (i32.load (global.get $pointer))
  )

  ;; Not yet implemented
  ;; (start $init)
)
