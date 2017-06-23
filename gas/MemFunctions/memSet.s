#Function: memSet
# PURPOSE: Intiliazie output buffer with a byte
#
# CALLING CONVENTION: C 
#	push input buffer address
#	push byte to initialize
#	push buffer size

# INPUT: 
#	input buffer address: a buffer to initialize
#	initial byte: initialization byte value
#	buffer size: an integer number 

# OUTPUT:
#	The initialized output buffer
#
# VARIABLES: The registers have the following uses
#
# %al  - initialization byte value
# %rcx - buffer size
# %rdi - buffer address
#
# CONSTANTS

# stack representation
.equ	ST_BUFFER_LEN, 16		# length of buffer (1*8 + 8)
.equ	ST_BYTE, 24				# initial byte (2*8 + 8)
.equ	ST_BUFFER, 32			# buffer address (3*8 + 8)

.type	memSet, @function
	.global	memSet
memSet:
	push	%rbp				# save stack for function return
	mov		%rsp, %rbp
	
	# Initialize
	mov		ST_BUFFER(%rbp), %rdi
	mov		ST_BYTE(%rbp), %rax
	mov		ST_BUFFER_LEN(%rbp), %rcx
	cld							# clear direction
	rep		stosb 				# copy al to destination rcx times

exit:
	mov	%rbp, %rsp		# restore stack for function return
	pop	%rbp
	ret	
