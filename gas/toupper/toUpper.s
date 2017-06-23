#Function: toUpper
# PURPOSE: Convert a buffer full of charactsr to upper case
#
# CALLING CONVENTION: C 
#	push buffer address
#	push buffer size

# INPUT: 
#	buffer address: a buffer with the charactes to convert
#	buffer size: an integer number 

# OUTPUT:
#	The buffer will be over-writtend with the upper case characters
#
# VARIABLES: The registers have the following uses
#
# %rax - beginning of the buffer
# %rbx - length of the buffer
# %rdi - current buffer offset
# %cl  - current byte being examined
#
# CONSTANTS
.equ	LOWERCASE_A, 'a' 		# 'a'
.equ	LOWERCASE_Z, 'z' 		# 'z'
.equ	UPPER_CONVERSION, 'A' - 'a'	# 
# stack representation
.equ	ST_BUFFER_LEN, 16		# length of buffer (1*8 + 8)
.equ	ST_BUFFER, 24			# buffer (2*8 + 8)

.type	toUpper, @function
	.global	toUpper
toUpper:
	push	%rbp			# save stack for function return
	mov	%rsp, %rbp
	
	# Initialize
	mov	ST_BUFFER(%rbp), %rax
	mov	ST_BUFFER_LEN(%rbp), %rbx
	xor	%rdi,%rdi

	cmp	$0, %rbx		# if length is 0, we're done
	je	exit

convertLoop:
	mov	(%rax,%rdi,1), %cl	# get current byte from buffer
	cmpb	$LOWERCASE_A, %cl	# only convert letters
	jl	next_byte
	cmpb	$LOWERCASE_Z, %cl
	jg 	next_byte
	addb	$UPPER_CONVERSION, %cl	# convert to uppercase
	mov	%cl, (%rax,%rdi,1)	# store back i buffer
next_byte:
	inc	%rdi			# move to next byte
	cmp	%rdi, %rbx		# all chacters converted?
	jne	convertLoop
exit:
	mov	%rbp, %rsp		# restore stack for function return
	pop	%rbp
	ret	
