	.text
	.file	"/b/build/slave/linux/build/src/src/work/gcc/gcc/testsuite/gcc.c-torture/execute/pr29156.c"
	.section	.text.bla,"ax",@progbits
	.hidden	bla
	.globl	bla
	.type	bla,@function
bla:                                    # @bla
	.param  	i32, i32
	.result 	i32
# BB#0:                                 # %entry
	i32.const	$push0=, 0
	i32.const	$push1=, 1
	i32.store	$push2=, global($pop0), $pop1
	i32.store	$discard=, 4($1), $pop2
	i32.const	$push3=, 8
	i32.store	$discard=, 0($0), $pop3
	i32.load	$push4=, 4($1)
	return  	$pop4
	.endfunc
.Lfunc_end0:
	.size	bla, .Lfunc_end0-bla

	.section	.text.main,"ax",@progbits
	.hidden	main
	.globl	main
	.type	main,@function
main:                                   # @main
	.result 	i32
	.local  	i32
# BB#0:                                 # %if.end
	i32.const	$0=, 0
	i32.const	$push0=, 1
	i32.store	$discard=, global($0), $pop0
	return  	$0
	.endfunc
.Lfunc_end1:
	.size	main, .Lfunc_end1-main

	.hidden	global                  # @global
	.type	global,@object
	.section	.bss.global,"aw",@nobits
	.globl	global
	.align	2
global:
	.int32	0                       # 0x0
	.size	global, 4


	.ident	"clang version 3.9.0 "
