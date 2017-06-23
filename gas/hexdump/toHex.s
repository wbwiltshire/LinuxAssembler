#Function: toHex
# PURPOSE: Convert a buffer full of characters to hex
#
# CALLING CONVENTION: C 
#	push input buffer address
#	push output buffer address
#	push input buffer size

# INPUT: 
#	input buffer address: a buffer with the data to convert
#	output buffer address: a buffer for the converted data
#	input buffer size: an integer number 

# OUTPUT:
#	The hex characters will be moved into the output buffer 
#
# VARIABLES: The registers have the following uses
#
# %rax - beginning of the input buffer
# %rbx - length of the buffer
# %rcx - beginning of the output buffer
# %rsi - current input buffer offset
# %rdi - current output buffer offset
# %cl  - current input byte being examined
# %rdx - working register
# #r10 - save register
#
# CONSTANTS

# stack representation
.equ	ST_BUFFER_LEN, 16		# length of buffer (1*8 + 8)
.equ	ST_OBUFFER, 24			# output buffer (2*8 + 8)
.equ	ST_IBUFFER, 32			# input buffer (3*8 + 8)

.type	toHex, @function
	.global	toHex
toHex:
	push	%rbp								# save stack for function return
	mov		%rsp, 				%rbp
	
	# Initialize
	mov		ST_IBUFFER(%rbp), 	%rax
	mov		ST_OBUFFER(%rbp), 	%rcx
	mov		ST_BUFFER_LEN(%rbp), %rbx
	xor		%rsi,				%rsi			# clean source/destination indexes
	xor		%rdi,				%rdi

	cmp		$0, 				%rbx			# if length is 0, we're done
	je		exit

convertLoop:
	xor 	%rdx, 				%rdx
	movw 	(%rax,%rsi), 		%r10			# get current word from buffer
	mov 	%r10, 				%rdx			# move to dx for conversion
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
	add		$2, 				%rdi			# move to next output section
	add		$2, 				%rsi			# move to next input word
	cmp		%rsi, 				%rbx			# all chacters converted?
	jg		convertLoop
exit:
	mov		%rbp, 				%rsp			# restore stack for function return
	pop		%rbp
	ret	
.data
HEX_TABLE:
	.ascii	"0123456789ABCDEF"					# Lookup table

