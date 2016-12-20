	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 12
	.section	__TEXT,__literal4,4byte_literals
	.p2align	2
LCPI0_0:
	.long	1065353216              ## float 1
LCPI0_1:
	.long	3212836864              ## float -1
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_draw
	.p2align	4, 0x90
_draw:                                  ## @draw
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp0:
	.cfi_def_cfa_offset 16
Ltmp1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp2:
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	callq	_glfwInit
	testl	%eax, %eax
	je	LBB0_8
## BB#1:
	leaq	L_.str(%rip), %rdx
	movl	$480, %edi              ## imm = 0x1E0
	movl	$320, %esi              ## imm = 0x140
	xorl	%ecx, %ecx
	xorl	%r8d, %r8d
	callq	_glfwCreateWindow
	movq	%rax, -16(%rbp)
	testq	%rax, %rax
	je	LBB0_7
## BB#2:
	movq	-16(%rbp), %rdi
	callq	_glfwMakeContextCurrent
	jmp	LBB0_4
	.p2align	4, 0x90
LBB0_3:                                 ##   in Loop: Header=BB0_4 Depth=1
	movl	$16384, %edi            ## imm = 0x4000
	callq	_glClear
	movl	$4, %edi
	callq	_glBegin
	xorps	%xmm1, %xmm1
	xorps	%xmm2, %xmm2
	movss	LCPI0_0(%rip), %xmm0    ## xmm0 = mem[0],zero,zero,zero
	callq	_glColor3f
	xorps	%xmm0, %xmm0
	xorps	%xmm2, %xmm2
	movss	LCPI0_0(%rip), %xmm1    ## xmm1 = mem[0],zero,zero,zero
	callq	_glVertex3f
	xorps	%xmm0, %xmm0
	xorps	%xmm2, %xmm2
	movss	LCPI0_0(%rip), %xmm1    ## xmm1 = mem[0],zero,zero,zero
	callq	_glColor3f
	xorps	%xmm2, %xmm2
	movss	LCPI0_1(%rip), %xmm0    ## xmm0 = mem[0],zero,zero,zero
	movaps	%xmm0, %xmm1
	callq	_glVertex3f
	xorps	%xmm0, %xmm0
	xorps	%xmm1, %xmm1
	movss	LCPI0_0(%rip), %xmm2    ## xmm2 = mem[0],zero,zero,zero
	callq	_glColor3f
	xorps	%xmm2, %xmm2
	movss	LCPI0_0(%rip), %xmm0    ## xmm0 = mem[0],zero,zero,zero
	movss	LCPI0_1(%rip), %xmm1    ## xmm1 = mem[0],zero,zero,zero
	callq	_glVertex3f
	callq	_glEnd
	movq	-16(%rbp), %rdi
	callq	_glfwSwapBuffers
	callq	_glfwPollEvents
LBB0_4:                                 ## =>This Inner Loop Header: Depth=1
	movq	-16(%rbp), %rdi
	callq	_glfwWindowShouldClose
	testl	%eax, %eax
	je	LBB0_3
## BB#5:
	movl	$0, -4(%rbp)
	jmp	LBB0_9
LBB0_7:
	callq	_glfwTerminate
LBB0_8:
	movl	$-1, -4(%rbp)
LBB0_9:
	movl	-4(%rbp), %eax
	addq	$32, %rsp
	popq	%rbp
	retq
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"Hello World"


.subsections_via_symbols
