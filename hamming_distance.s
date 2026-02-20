	.section .rodata
p1: .asciz "Enter first string: "
p2: .asciz "Enter second string: "
of: .asciz "Hamming distance: %d\n"

th: .asciz "\n[TEST MODE]\n"
tf: .asciz "Test %d: \"%s\" vs \"%s\" => got %d, expected %d : %s\n"
ps: .asciz "PASS"
fs: .asciz "FAIL"
td: .asciz "[END TESTS]\n"

a1: .asciz "foo"
b1: .asciz "bar"
a2: .asciz "this is a test"
b2: .asciz "of the emergency broadcast"
a3: .asciz "abc"
b3: .asciz "abc"
a4: .asciz "A"
b4: .asciz "B"
a5: .asciz ""
b5: .asciz "anything"
a6: .asciz "a"
b6: .asciz "abcd"

	.section .data
tbl:
	.quad a1, b1
	.long 8, 0
	.quad a2, b2
	.long 38, 0
	.quad a3, b3
	.long 0, 0
	.quad a4, b4
	.long 2, 0
	.quad a5, b5
	.long 0, 0
	.quad a6, b6
	.long 0, 0
tbl_end:

	.section .bss
	.lcomm buf1, 256
	.lcomm buf2, 256

	.section .text
	.globl main
	.type main, @function

	.extern printf
	.extern fgets
	.extern strlen
	.extern stdin
	.extern strcmp

	.type pc, @function
pc:
	xorl    %eax, %eax
	movl    %edi, %ecx
	andl    $0xFF, %ecx
Lpc1:
	testl   %ecx, %ecx
	je      Lpc2
	leal    -1(%ecx), %edx
	andl    %edx, %ecx
	incl    %eax
	jmp     Lpc1
Lpc2:
	ret

	.type sn, @function
sn:
Lsn1:
	movzbq  (%rdi), %rax
	testb   %al, %al
	je      Lsn3
	cmpb    $10, %al
	je      Lsn2
	incq    %rdi
	jmp     Lsn1
Lsn2:
	movb    $0, (%rdi)
Lsn3:
	ret

	.type mn, @function
mn:
	movq    %rdi, %rax
	cmpq    %rsi, %rax
	cmovaq  %rsi, %rax
	ret

	.type ham, @function
ham:
	pushq   %rbp
	movq    %rsp, %rbp
	pushq   %rbx
	pushq   %r12
	pushq   %r13
	pushq   %r14
	pushq   %r15
	subq    $8, %rsp

	movq    %rdi, %r13
	movq    %rsi, %r14

	movq    %r13, %rdi
	call    strlen
	movq    %rax, %r15

	movq    %r14, %rdi
	call    strlen
	movq    %rax, %rbx

	movq    %r15, %rdi
	movq    %rbx, %rsi
	call    mn
	movq    %rax, %rbx

	xorl    %r12d, %r12d
	xorl    %r15d, %r15d

Lh1:
	cmpq    %rbx, %r12
	jae     Lh2

	movzbl  (%r13,%r12,1), %eax
	movzbl  (%r14,%r12,1), %edx
	xorl    %edx, %eax

	movl    %eax, %edi
	call    pc
	addl    %eax, %r15d

	incq    %r12
	jmp     Lh1

Lh2:
	movl    %r15d, %eax

	addq    $8, %rsp
	popq    %r15
	popq    %r14
	popq    %r13
	popq    %r12
	popq    %rbx
	popq    %rbp
	ret

	.type rt, @function
rt:
	pushq   %rbp
	movq    %rsp, %rbp
	pushq   %rbx
	pushq   %r12
	pushq   %r13
	pushq   %r14
	pushq   %r15
	subq    $8, %rsp

	leaq    th(%rip), %rdi
	xorl    %eax, %eax
	call    printf

	leaq    tbl(%rip), %r13
	leaq    tbl_end(%rip), %r14
	movl    $1, %r12d

Lt1:
	cmpq    %r14, %r13
	jae     Lt2

	movq    0(%r13), %rbx
	movq    8(%r13), %r15
	movl    16(%r13), %r11d

	movq    %rbx, %rdi
	movq    %r15, %rsi
	call    ham
	movl    %eax, %r10d

	leaq    ps(%rip), %r9
	cmpl    %r11d, %r10d
	je      Lt_ok
	leaq    fs(%rip), %r9
Lt_ok:
	leaq    tf(%rip), %rdi
	movl    %r12d, %esi
	movq    %rbx, %rdx
	movq    %r15, %rcx
	movl    %r10d, %r8d

	# 6th+ printf args go on stack
	pushq   %r9
	pushq   %r11
	xorl    %eax, %eax
	call    printf
	addq    $16, %rsp

	addq    $24, %r13
	incl    %r12d
	jmp     Lt1

Lt2:
	leaq    td(%rip), %rdi
	xorl    %eax, %eax
	call    printf

	addq    $8, %rsp
	popq    %r15
	popq    %r14
	popq    %r13
	popq    %r12
	popq    %rbx
	popq    %rbp
	ret

main:
	pushq   %rbp
	movq    %rsp, %rbp
	pushq   %rbx
	subq    $8, %rsp

	cmpl    $2, %edi
	jl      Min

	movq    8(%rsi), %rbx
	movq    %rbx, %rdi
	leaq    targ(%rip), %rsi
	call    strcmp
	testl   %eax, %eax
	jne     Min

	call    rt
	xorl    %eax, %eax
	addq    $8, %rsp
	popq    %rbx
	popq    %rbp
	ret

Min:
	leaq    p1(%rip), %rdi
	xorl    %eax, %eax
	call    printf

	leaq    buf1(%rip), %rdi
	movl    $256, %esi
	movq    stdin(%rip), %rdx
	call    fgets

	leaq    p2(%rip), %rdi
	xorl    %eax, %eax
	call    printf

	leaq    buf2(%rip), %rdi
	movl    $256, %esi
	movq    stdin(%rip), %rdx
	call    fgets

	leaq    buf1(%rip), %rdi
	call    sn
	leaq    buf2(%rip), %rdi
	call    sn

	leaq    buf1(%rip), %rdi
	leaq    buf2(%rip), %rsi
	call    ham

	leaq    of(%rip), %rdi
	movl    %eax, %esi
	xorl    %eax, %eax
	call    printf

	xorl    %eax, %eax
	addq    $8, %rsp
	popq    %rbx
	popq    %rbp
	ret

targ:
	.asciz "--test"
