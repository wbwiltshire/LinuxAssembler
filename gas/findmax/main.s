#Purpose: Find the max number in a list
#
# Written for Linux x86_64
# VARIABLES: The registers have the following users
#
# %r prefix means 64 bit registers
# %e prefix means 32 bit registers
#
# %eax - current data item 
# %edx - largest data item found
# %edi - index of the data item being examined
#
#  dataItems - contains the list with \0 used to terminate the data
#
# CONSTANTS
.equ	STDOUT, 1
.equ	SYS_WRITE, 1
.equ	SYS_EXIT, 60

# DATA SECTION
.data
maxNbr:
.ascii	"000\0\n"
	lenMax =   . - maxNbr
msg:
.ascii  "Found the max number: "
	lenMsg =   . - msg
dataItems:
.long	3,67,34,222,45,75,54,34,44,33,22,11,66,0

# CODE SECTION
.text
# MACROS
.macro SYSEXIT exitCd
	mov	$SYS_EXIT, %rax		# system call 60 is exit
	xor	\exitCd, %rdi		# set return code 
	syscall				# make system call
.endm
.macro SYSPRINT sMsg, sLength
	mov	$SYS_WRITE, %rax	# move value 1 into reg. ax for 'write' system call
	mov	$STDOUT, %rdi		# file handle is 1 for stdout
	mov	\sMsg, %rsi		# move address of string to output
	mov	\sLength, %rdx		# numbe of bytes to output
	syscall				# make system call
.endm

# Start of main program
	.global	_start

_start:
	# Initialiize
	xor	%edi, %edi			# set the index register to 0
	movl	dataItems(,%edi,4), %eax	# load the first item in the list
	movl	%eax, %ebx			# since this is first item, it's the biggest

	# Loop until end of list
maxLoop:
	cmpl	$0, %eax		# see if we've hit the end of the list
	je maxExit
	incl	%edi			# load next value
	movl	dataItems(,%edi,4), %eax	
	cmpl	%ebx, %eax		# compare to old max
	jle	maxLoop			# back to top of loop, if not bigger
	movl	%eax, %ebx		# update with new max
	jmp	maxLoop			# back to top of loop
maxExit:
	# Convert to ASCII
	push	$maxNbr			# push buffer address
	push    %rbx			# push the number to convert
	call	intToString 	
	add	$16, %ebp		# reset stack for 2 parms (buffer & number) added above

	# Print out answer
	SYSPRINT $msg, $lenMsg
	SYSPRINT $maxNbr, $lenMax

        # Return exit(0)
	SYSEXIT $0
