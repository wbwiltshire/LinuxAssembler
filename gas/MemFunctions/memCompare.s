#Function: memCompare
# PURPOSE: compare bytes from input buffer to output buffer
#
# CALLING CONVENTION: C 
#	push input buffer address
#	push output buffer address
#	push input buffer size

# INPUT: 
#	input buffer address: a buffer with the data to copy
#	output buffer address: a buffer for the copied data
#	input buffer size: an integer number 

# OUTPUT:
#	The bytes will be copied from the input buffer into the output buffer 
#
# VARIABLES: The registers have the following uses
#
# %rcx - length to compare
# %rsi - input buffer
# %rdi - output buffer
#
# CONSTANTS

# stack representation
.equ	ST_BUFFER_LEN, 16		# length of buffer (1*8 + 8)
.equ	ST_OBUFFER, 24			# output buffer (2*8 + 8)
.equ	ST_IBUFFER, 32			# input buffer (3*8 + 8)

.type	memCompare, @function
	.global	memCompare
memCompare:
	push	%rbp			# save stack for function return
	mov		%rsp, %rbp
		
	# Copy
	mov		ST_IBUFFER(%rbp), %rsi
	mov		ST_OBUFFER(%rbp), %rdi
	mov		ST_BUFFER_LEN(%rbp), %rcx
	cld						# clear direction
	rep		cmpsb 			# copy source to destination rcx times
	jz		success
	mov		$0xff, %rax		# indicate failure
	jmp		exit
success:
	xor		%rax, %rax		# indicate success
	
exit:
	mov		%rbp, %rsp		# restore stack for function return
	pop		%rbp
	ret	
