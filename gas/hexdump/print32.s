#Function: print32
# PURPOSE: Convert the lower 32 bits of a 64 bit value to a hex string
#
# CALLING CONVENTION: C 
#	push value in 64 bit register
#	push output buffer address

# INPUT: 
#	value: a value (quad) to convert
#	output buffer address: a buffer for the converted data

# OUTPUT:
#	The hex characters will be moved into the output buffer 
#
# VARIABLES: The registers have the following uses
#
# %rax - value to convert
# %rcx - beginning of the output buffer
# %rdi - current output buffer offset
# %rbx - count register
# %rdx - working register
# #r10 - save register
#
# CONSTANTS

# stack representation
.equ	ST_OBUFFER, 16		# output buffer (1*8 + 8)
.equ	ST_VALUE, 24		# register value to convert (2*8 + 8)

.type	print32, @function
	.global	print32
print32:
	push	%rbp								# save stack for function return
	mov		%rsp, 				%rbp
	
	# Initialize
	mov		ST_VALUE(%rbp), 	%rax
	mov		ST_OBUFFER(%rbp), 	%rcx
	
	cmp		$0, 				%eax			# if value is 0, we're done
	je		exit

	mov 	$2, 				%rbx			# set words to convert
	xor		%rdx,				%rdx			# zero out rdx
	mov		%eax,				%edx			# move value to edx for conversion
	mov		%rdx,				%r10			# save orginal value
	mov		$4,					%rdi			# set low order output	
convertLoop:
	shr		$12, 				%rdx			# expose high order nibble
	andw 	$15, 				%rdx			# mask nibble
	movb 	HEX_TABLE(%rdx), 	%dl				# get hex digit from table
	movb 	%dl, 				(%rcx,%rdi,1)	# store in output buffer
	inc		%rdi								# move to next output location
	mov		%r10, 				%rdx			# restore value
	shr		$8, 				%rdx			# expose next nibble
	andw 	$15, 				%rdx			# mask nibble
	movb 	HEX_TABLE(%rdx), 	%dl
	mov 	%dl, 				(%rcx,%rdi,1)	# store in output buffer
	inc		%rdi								# move next output location
	mov		%r10, 				%rdx			# restore value
	shr		$4, 				%rdx			# expose next nibble
	andw 	$15, 				%rdx			# mask nibble
	movb 	HEX_TABLE(%rdx), 	%dl
	mov 	%dl, 				(%rcx,%rdi,1)	# store in output buffer
	inc		%rdi
	mov		%r10, 				%rdx			# restore value
	andw 	$15, 				%rdx			# mask nibble
	movb 	HEX_TABLE(%rdx), 	%dl
	mov 	%dl, 				(%rcx,%rdi,1)	# store in output buffer
	mov		%eax,				%edx			# restore original value
	shr		$16,				%edx			# work on high order
	mov		%rdx,				%r10			# save value
	xor		%rdi,				%rdi			# reset output position
	dec		%rbx								# move to next word in value
	jnz		convertLoop

exit:
	mov		%rbp, 				%rsp			# restore stack for function return
	pop		%rbp
	ret	
.data
HEX_TABLE:
	.ascii	"0123456789ABCDEF"					# Lookup table
	