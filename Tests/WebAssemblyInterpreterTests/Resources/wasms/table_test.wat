(module
    ;; table_export.watから4つのanyfunc関数を含むテーブルをインポートする
    (import "js" "tbl" (table $tbl 4 funcref))

    ;; JavaScriptから関数をインポートする
    (import "js" "increment" (func $increment (result i32)))
    (import "js" "decrement" (func $decrement (result i32)))

    ;; table_export.watのテーブルで定義されている関数をインポート
    (import "js" "wasm_increment" (func $wasm_increment (result i32)))
    (import "js" "wasm_decrement" (func $wasm_decrement (result i32)))

    ;; テーブル内の関数のシグネチャを定義
    ;; テーブル関数の型定義は全てi32であり、パラメータはない
    (type $returns_i32 (func (result i32)))

    ;; 関数テーブルをインデックス参照するために４つのグローバル変数を定義する
    (global $inc_ptr i32 (i32.const 0))
    (global $dec_ptr i32 (i32.const 1))
    (global $wasm_inc_ptr i32 (i32.const 2))
    (global $wasm_dec_ptr i32 (i32.const 3))

    ;; ========== 以下テスト関数 ==========

    ;; JavaScript関数の間接的な呼び出しのパフォーマンスをテスト
    (func (export "js_table_test")
        (loop $inc_cycle
            ;; JavaScriptのincrement関数を間接的に呼び出す
            (call_indirect (type $returns_i32) (global.get $inc_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle ;; $inc_ptrから返された値が4,000,000以下ならループを繰り返す
        )
        (loop $dec_cycle
            ;; JavaScriptのdecrement関数を間接的に呼び出す
            (call_indirect (type $returns_i32) (global.get $dec_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle ;; $dec_ptrから返された値が4,000,000以下ならループを繰り返す
        )
    )

    ;; JavaScript関数の直接的な呼び出しのパフォーマンスをテスト
    (func (export "js_import_test")
        (loop $inc_cycle
            ;; JavaScriptのincrement関数を直接的に呼び出す
            call $increment
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle ;; $inc_ptrから返された値が4,000,000以下ならループを繰り返す
        )
        (loop $dec_cycle
            ;; JavaScriptのdecrement関数を直接的に呼び出す
            call $decrement
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle ;; $dec_ptrから返された値が4,000,000以下ならループを繰り返す
        )
    )

    ;; WASM関数の間接的な呼び出しのパフォーマンスをテスト
    (func (export "wasm_table_test")
        (loop $inc_cycle
            ;; WASMのincrement関数を間接的に呼び出す
            (call_indirect (type $returns_i32) (global.get $wasm_inc_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle ;; $inc_ptrから返された値が4,000,000以下ならループを繰り返す
        )
        (loop $dec_cycle
            ;; WASMのdecrement関数を間接的に呼び出す
            (call_indirect (type $returns_i32) (global.get $wasm_dec_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle ;; $dec_ptrから返された値が4,000,000以下ならループを繰り返す
        )
    )

    ;; WASM関数の直接的な呼び出しのパフォーマンスをテスト
    (func (export "wasm_import_test")
        (loop $inc_cycle
            ;; WASMのincrement関数を直接的に呼び出す
            call $increment
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle ;; $inc_ptrから返された値が4,000,000以下ならループを繰り返す
        )
        (loop $dec_cycle
            ;; WASMのdecrement関数を直接的に呼び出す
            call $decrement
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle ;; $dec_ptrから返された値が4,000,000以下ならループを繰り返す
        )
    )
)