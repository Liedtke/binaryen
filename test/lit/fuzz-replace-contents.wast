;; Test the flag to replace the contents of initial fuzz content.

;; With --fuzz-replace-contents, the public interface (imports, exports, start)
;; is preserved exactly, as with --fuzz-preserve-imports-exports alone, but
;; everything private to the module is discarded and regenerated. This keeps
;; chained mutations from growing the module without bound.

;; Generate once, then check the result twice: the positive checks below need to
;; run in order against the output, while the negative ones need to see all of
;; it. A CHECK-NOT is only scanned over the range between its neighbouring
;; positive matches, so mixing the two in one filecheck invocation would limit
;; the negative checks to whatever gap they happened to sit in - which silently
;; makes them pass no matter what the output contains. Giving them a prefix of
;; their own, with no positive checks, scans them over the whole input.

;; RUN: wasm-opt %s.dat --initial-fuzz=%s -all -ttf \
;; RUN:          --fuzz-preserve-imports-exports --fuzz-replace-contents \
;; RUN:          --metrics -S -o - > %t.wat
;; RUN: filecheck %s --check-prefix=REPLACE < %t.wat
;; RUN: filecheck %s --check-prefix=GONE < %t.wat

;; The private content is discarded. $private_helper was referred to by an
;; element segment and $private_table_init by the exported table's initializer;
;; neither may be left dangling.
;; GONE-NOT: $private_helper
;; GONE-NOT: $private_global
;; GONE-NOT: $private_table_init

;; The interface is preserved, exactly as without this flag.
;; REPLACE: [exports]      : 2
;; REPLACE: [imports]      : 5

;; [sic] - we do not close ("))") some imports, which have info in the wat
;; which we do not care about.
;; REPLACE:  (import "a" "d" (memory $imemory
;; REPLACE:  (import "a" "e" (table $itable
;; REPLACE:  (import "a" "b" (global $iglobal i32))
;; REPLACE:  (import "a" "f" (func $ifunc
;; REPLACE:  (import "a" "c" (tag $itag

;; The exported table survives, but its initializer, which referred to a
;; private function, has been replaced with a null rather than carried forward.
;; REPLACE:  (table $etable 2 funcref (ref.null nofunc))

;; The exports are preserved.
;; REPLACE:  (export "foo" (func $foo))
;; REPLACE:  (export "etable" (table $etable))

;; The start function is preserved.
;; REPLACE:  (start $on_load)

;; Without --fuzz-replace-contents, the private helper survives.

;; RUN: wasm-opt %s.dat --initial-fuzz=%s -all -ttf \
;; RUN:          --fuzz-preserve-imports-exports \
;; RUN:          -S -o - | filecheck %s --check-prefix=KEEP

;; KEEP: $private_helper

;; The flag requires --fuzz-preserve-imports-exports.

;; RUN: not wasm-opt %s.dat --initial-fuzz=%s -all -ttf \
;; RUN:              --fuzz-replace-contents 2>&1 | filecheck %s --check-prefix=ERROR

;; ERROR: Fatal: --fuzz-replace-contents requires --fuzz-preserve-imports-exports

(module
  ;; Existing imports, which must be preserved.
  (import "a" "b" (global $iglobal i32))
  (import "a" "c" (tag $itag))
  (import "a" "d" (memory $imemory 10 20))
  (import "a" "e" (table $itable 10 20 funcref))
  (import "a" "f" (func $ifunc))

  (start $on_load)

  ;; One existing export.
  (func $foo (export "foo")
  )

  (func $on_load
    (call $ifunc)
  )

  ;; Private content, which --fuzz-replace-contents should discard. The
  ;; element segment referring to $private_helper checks that we do not leave a
  ;; dangling reference behind when removing it.
  (func $private_helper
    (nop)
  )

  (global $private_global i32 (i32.const 42))

  (elem (i32.const 0) $private_helper)

  ;; An exported table whose initializer refers to a private function. The
  ;; initializer is content, not interface, so it must be replaced rather than
  ;; carried forward: retaining it would leave a dangling reference once
  ;; $private_table_init is removed.
  (table $etable (export "etable") 2 2 funcref (ref.func $private_table_init))

  (func $private_table_init
    (nop)
  )
)

