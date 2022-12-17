(module
    (import "env" "print_value" (func $print_value(param i32)))
    (import "env" "print_fizz" (func $print_fizz))
    (import "env" "print_buzz" (func $print_buzz))
    (import "env" "print_fizzbuzz" (func $print_fizzbuzz))

    (func (export "fizzbuzz") (param $n i32)
        (local $i i32)
        (local.set $i (i32.const 1))

        (loop $continue (block $break
            local.get $i
            i32.const 15
            i32.rem_u
            i32.const 0
            i32.eq
            if
                (call $print_fizzbuzz)
            else
                local.get $i
                i32.const 3
                i32.rem_u
                i32.const 0
                i32.eq
                if
                    (call $print_fizz)
                else
                    local.get $i
                    i32.const 5
                    i32.rem_u
                    i32.const 0
                    i32.eq
                    if
                        (call $print_buzz)
                    else
                        (call $print_value (local.get $i))
                    end
                end
            end

            (local.set $i
                (i32.add (local.get $i) (i32.const 1))
            )
            (br_if $break
                (i32.eq (local.get $i) (local.get $n))
            )
            br $continue
        ))
    )
)