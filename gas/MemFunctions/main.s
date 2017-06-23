#Purpose: Test harness for memory functions
#
# Written for Linux x86_64
# VARIABLES: The registers have the following users
#
# %r prefix means 64bit registers
#
# CONSTANTS
.equ	STDOUT, 1
.equ	SYS_WRITE, 1
.equ	SYS_EXIT, 60
.equ	BUF_SZ, 512

.bss
	.lcomm	outBuffer, BUF_SZ
.data
inBuffer:
.rep	BUF_SZ
	.quad	0xFFFFFFFFFFFFFFFF
.endr
zeroBuffer:
.rep	BUF_SZ
	.quad	0x0
.endr
copyMsg:
.ascii  "Performing memcpy\n"
	lenCopyMsg =   . - copyMsg
setMsg:
.ascii  "Performing memset\n"
	lenSetMsg =   . - setMsg
matchMsg:
.ascii  "Validation success\n"
	lenmm =   . - matchMsg
failMsg:
.ascii  "Validation fail\n"
	lenfm =   . - failMsg
.text
# MACROS
.include "macros.inc"

	.global	_start

_start:
	#Initialize
	mov 	%rsp, %rbp		# save the stack pointer	

	push	$outBuffer		# set output buffer
	xor		%rax, %rax		# set initial byte to 0
	push	%rax			
	push	$BUF_SZ			# set buffer size
	call	memSet
	SYSPRINT $setMsg, $lenSetMsg
	add		$24, %rsp		# cleanup stack

	# Validate
	push	$zeroBuffer		# set input buffer
	push	$outBuffer		# set output buffer
	push	$BUF_SZ			# set buffer size
	call	memCompare
	add	$24, %rsp			# cleanup stack

	or		%rax, %rax		# set EFLAGS
	jz		setMatch		# rax is 0, if they match
	SYSPRINT $failMsg, $lenfm
	jmp		copy
setMatch:
	SYSPRINT $matchMsg, $lenmm

copy:
	push	$inBuffer		# set input buffer
	push	$outBuffer		# set output buffer
	push	$BUF_SZ			# set buffer size
	call	memCopy
	SYSPRINT $copyMsg, $lenCopyMsg
	add	$24, %rsp		# cleanup stack

	# Validate
	push	$inBuffer		# set input buffer
	push	$outBuffer		# set output buffer
	push	$BUF_SZ			# set buffer size
	call	memCompare
	add	$24, %rsp		# cleanup stack

	or		%rax, %rax		# set EFLAGS
	jz		copyMatch		# rax is 0, if they match
	SYSPRINT $failMsg, $lenfm
	jmp		exit
copyMatch:
	SYSPRINT $matchMsg, $lenmm
	
exit:
    # Return exit(0)
	SYSEXIT	$0		# return to OS with exit code
