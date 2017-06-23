# FUNCTION: printElapsed
#
# PURPOSE: Print integer to console3
#
# CALLING CONVENTION: Linux X86_64 ABI
# %r prefix for 64bit registers
#
# INPUT:
#   %rdi - call parameter 1 (integer to print)

# OUTPUT:
#	None
#
# VARIABLES: The registers have the following uses
#
# %rax - division of integer
# %rbx - length of the buffer
# %rcx - digit count
# %rdx - division of integer
# %rdi - divisor
#
# CONSTANTS
.equ    STDIN, 0
.equ    STDOUT, 1
.equ    STDERR, 2
.equ    SYS_OPEN, 2
.equ    SYS_CLOSE, 3
.equ    SYS_READ, 0
.equ    SYS_WRITE, 1
.equ    SYS_EXIT, 60

.data
buffer:
.rep	80
	.byte	'\0'
.endr

.text
.include "macros.inc"
.type   printElapsed, @function
        .global printElapsed

printElapsed:
        push    %rbp            # save stack for function return
        mov     %rsp, %rbp

        # Initialize
	mov	%rdi, %rax	# move integer for division
	xor	%rcx, %rcx	# 0 the digit count
        xor	%r8, %r8        # zero counter for printing ','
	mov	$10, %rdi	# setup for divide by 10
convert:
        xor	%rdx, %rdx      # devision done on combined rdx:rax, so 0 %rdx
	# Start dividing
        div	%rdi		# quotient in %rax, remainder in %rdx
	add	$'0', %rdx	# convert to ascii digit
        inc	%r8             # inc count for ','
        cmp	$4, %r8         # if processed 4 digits, print a ','
        je	addComma
nextDigit:
	push	%rdx		# save digit
	inc	%rcx		# increment digit count
	cmp 	$0, %rax	# if remainer is 0, we're done
	jne	convert

	# Move from stack to bufffer
	mov	$buffer, %rdx
	mov	%rcx, %rbx	# save the digit count
save:
	pop	%rax		# get digit from stack
	mov	%al, (%rdx)	# save it in the buffer
	dec	%rcx		# decrement digit count
	inc	%rdx		# move buffer ptr
	cmp	$0, %rcx	# all digits moved?
	jne	save
	movb	$0, (%rdx)	# terminate string with null byte
	
	SYSPRINT $buffer, %rbx  # print the number 
exit:
        mov %rbp, %rsp          # restore stack for function return
        pop %rbp
        ret
addComma:
	xor	%rsi, %rsi      # clear for store
        add	$',', %rsi      # store ','
        push	%rsi            # store ','
	inc	%rcx		# increment digit count
        mov	$1, %r8         # zero counter for printing ','
	jmp	nextDigit
