(module
  ;; 偶数チェック
  (func $even_check (param $n i32) (result i32)
    local.get $n
    i32.const 2
    i32.rem_u ;; 2で割った余りを使う場合
    i32.const 0 ;; 偶数のあまりは0になる
    i32.eq ;; $n % 2 == 0 の場合は1を返す
  )

  ;; 2であるかチェック
  (func $eq_2 (param $n i32) (result i32)
    local.get $n
    i32.const 2
    i32.eq ;; $n == 2 の場合は1を返す
  )

  ;; $n が $m の倍数であるかチェック
  (func $multiple_check (param $n i32) (param $m i32) (result i32)
    local.get $n
    local.get $m
    i32.rem_u ;; $n / $m の余り
    i32.const 0
    i32.eq
  )

  ;; 32ビット整数を受け取り素数判定を行う
  ;; 戻り値は素数である場合は1,素数でない場合は0となる
  (func (export "is_prime") (param $n i32) (result i32)
    (local $i i32) ;; ループカウンタ

    ;; $n == 1 をチェック
    (if (i32.eq (local.get $n) (i32.const 1))
      (then
        i32.const 0 ;; 1は素数ではない
        return
      )
    )

    ;; $n == 2 をチェック
    (if (call $eq_2 (local.get $n))
      (then
        i32.const 1 ;; 2は素数
        return
      )
    )

    (block $not_prime
      (call $even_check (local.get $n))
      br_if $not_prime ;; （２以外の）偶数は素数ではない

      (local.set $i (i32.const 1))

      (loop $prime_test_loop
        (local.tee $i
          (i32.add (local.get $i) (i32.const 2))) ;; $i += 2
        
        local.get $n ;; stack = [$n, $i]

        i32.ge_u ;; $i >= $n
        if ;; $i >= $n の場合、nは素数
          i32.const 1
          return
        end

        (call $multiple_check (local.get $n) (local.get $i))

        br_if $not_prime ;; $n が $i の倍数の場合は素数ではない
        br $prime_test_loop ;; ループの先頭に戻る
      ) ;; $prime_test_loop の終わり
    ) ;; $not_prime ブロックの終わり
    i32.const 0 ;; 素数ではないのでfalseを返す
  )
)