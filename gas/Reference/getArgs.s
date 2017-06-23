# FUNCTION: getArgs
#
# PURPOSE: Read and store the command line arguements
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
.equ	STDIN, 0
.equ	STDOUT, 1
.equ	STDERR, 2
.equ	SYS_WRITE, 1

# stack representation
.equ	ST_ARG_ADDR, 48		# argument count (5*8 + 8)
.equ	ST_ARGC, 40			# argument count (4*8 + 8)
.equ	ST_ARGC_ADDR, 32	# argument count (3*8 + 8)
.equ	ST_ARG_PTRS, 24		# argument pointers (2*8 + 8)
.equ	ST_ARG_LENS, 16		# argument lengths (1*8 + 8)

.text
.include "macros.inc"
.type   getArgs, @function
        .global getArgs

getArgs:
        push    %rbp            	# save stack for function return
        mov     %rsp, %rbp
		
    # Save the the argument count
	mov		ST_ARGC(%rbp), %rax		# get value from stack
	mov		ST_ARGC_ADDR(%rbp), %rbx # get address from stack
	mov     %rax, (%rbx)   			# save value to address 

    # Save the the list of argument address pointers
	mov		%rax, %r8				# save arg count
	xor		%rdi, %rdi				# zero index
	xor     %rsi, %rsi      		# zero index
	xor		%rbx, %rbx				# set offset
	mov		%rbp, %rcx 				# get argument pointer address from command line into %rcx
	add		$ST_ARG_ADDR, %rcx 		
	mov		ST_ARG_PTRS(%rbp), %rdx	# get address to store argument pointers
savePtrs:
	add		%rbx, %rcx
	add		%rbx, %rdx
	mov		(%rcx), %r9
	mov     %r9,(%rdx)  	 		# save argument address in table
	add		$8, %rbx
	inc		%rsi
	cmp     %rsi, %r8
	jg      savePtrs        		# continue until all argument pointers processed

	# Save the the argument lengths to a table
	xor     %rsi, %rsi              # zero the index
	xor     %r9, %r9              	# zero the offset
	mov		ST_ARG_PTRS(%rbp), %rbx	# get address of argument pointers
	mov		ST_ARG_LENS(%rbp), %rdx	# get address to store argument lengths
	# rax : search string
	# rbx : address of argument pointers
	# rcx : string length
	# rdx : address to store argument lengths
	# rdi : address to scan
	# rsi : index to argument lengths
	# r8  : argument count
	# r9  : offset
getLengths:
	xor     %rcx, %rcx              # set max string len
	not     %rcx
	add		%r9, %rbx				# get address of argument pointers from stack
	mov     (%rbx), %rdi  			# get argument address to scan
	xor     %rax, %rax              # search for null string terminator '\0'
	cld                             # clear the direction flag
	repne   scasb                   # scan string byte by byte
	jnz     error                   # jump if we don't find null terminator
	not     %rcx                    # compute the length
	dec     %rcx
	add		%r9, %rdx
	mov     %rcx, (%rdx)  			# store length in table
	add		$8, %r9
	inc     %rsi
	cmp     %rsi, %r8            	# compare to number of args
	jg		getLengths              # continue until all arguments processed

	# Used for debugging - print arg count and arguments
printArgs: 
	mov		ST_ARGC_ADDR(%rbp), %rbx # get argument count address from stack
	mov     (%rbx), %rax   			 # get count value, count actually in %al 

	add		$'0', %rax				# make printable
	push	%rax					#
    mov     $SYS_WRITE, %rax        # write operation
    mov     $STDOUT, %rdi			# to STDOUT
    mov    	%rsp, %rsi				# move character to write to stack        
    mov     $1, %rdx    			# length to write
    syscall                     
	add 	$8, %rsp				# restore stack pointer
	SYSPRINT $newLine, $1			# print newline

	mov		ST_ARG_PTRS(%rbp), %rcx	 # get address of argument pointers	
	mov		%rcx, %r8				 # save it
	mov		(%rcx), %rcx
	mov		ST_ARG_LENS(%rbp), %rdx	 # get address of argument lengths	
	mov		%rdx, %r9				 # save it
	mov		(%rdx), %rdx
	SYSDEBUG %rcx, %rdx				# print 1st argument (progname)
	add		$8, %r8					# move to next argument
	mov		%r8, %rcx
	mov		(%rcx), %rcx			
	add		$8, %r9					# move to next length
	mov		%r9, %rdx
	mov		(%rdx), %rdx
	SYSDEBUG %rcx, %rdx				# print 2st argument (filename)

exit:
	mov 	%rbp, %rsp          	# restore stack for function return
	pop 	%rbp
	ret
error:
	mov		$0, %rax				# on error, return 0 for arg count
	mov		ST_ARGC_ADDR(%rbp), %rbx # get address from stack
	mov     %rax, (%rbx)   			# save value to address 
	jmp 	exit
.data
newLine:
.ascii	"\n"
