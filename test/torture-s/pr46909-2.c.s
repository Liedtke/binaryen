	.text
	.file	"/b/build/slave/linux/build/src/src/work/gcc/gcc/testsuite/gcc.c-torture/execute/pr46909-2.c"
	.section	.text.foo,"ax",@progbits
	.hidden	foo
	.globl	foo
	.type	foo,@function
foo:                                    # @foo
	.param  	i32
	.result 	i32
	.local  	i32
# BB#0:                                 # %entry
	block
	block
	i32.const	$push0=, 13
	i32.eq  	$push1=, $0, $pop0
	br_if   	$pop1, 0        # 0: down to label1
# BB#1:                                 # %entry
	i32.const	$1=, 1
	br_if   	$0, 1           # 1: down to label0
.LBB0_2:                                # %if.end
	end_block                       # label1:
	i32.const	$1=, -1
.LBB0_3:                                # %return
	end_block                       # label0:
	return  	$1
	.endfunc
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo

	.section	.text.main,"ax",@progbits
	.hidden	main
	.globl	main
	.type	main,@function
main:                                   # @main
	.result 	i32
	.local  	i32, i32, i32, i32
# BB#0:                                 # %entry
	i32.const	$3=, -10
.LBB1_1:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
	block
	loop                            # label3:
	i32.call	$0=, foo@FUNCTION, $3
	i32.const	$1=, 0
	i32.const	$2=, 1
	i32.eq  	$push0=, $3, $1
	i32.shl 	$push1=, $pop0, $2
	i32.sub 	$push2=, $2, $pop1
	i32.const	$push3=, 13
	i32.eq  	$push4=, $3, $pop3
	i32.shl 	$push5=, $pop4, $2
	i32.sub 	$push6=, $pop2, $pop5
	i32.ne  	$push7=, $0, $pop6
	br_if   	$pop7, 2        # 2: down to label2
# BB#2:                                 # %for.cond
                                        #   in Loop: Header=BB1_1 Depth=1
	i32.add 	$3=, $3, $2
	i32.const	$push8=, 29
	i32.le_s	$push9=, $3, $pop8
	br_if   	$pop9, 0        # 0: up to label3
# BB#3:                                 # %for.end
	end_loop                        # label4:
	return  	$1
.LBB1_4:                                # %if.then
	end_block                       # label2:
	call    	abort@FUNCTION
	unreachable
	.endfunc
.Lfunc_end1:
	.size	main, .Lfunc_end1-main


	.ident	"clang version 3.9.0 "
