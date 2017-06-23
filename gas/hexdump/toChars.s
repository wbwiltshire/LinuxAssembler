#Function: toUpper
# PURPOSE: Convert a buffer full of bytes to ascii characters
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
#	The ascii characters will be moved into the output buffer 
#
# VARIABLES: The registers have the following uses
#
# %rax - beginning of the input buffer
# %rbx - length of the buffer
# %cl  - current byte being examined
# %rdx - beginning of the output buffer
# %rdi - current input buffer offset
# %rdi - current input buffer offset
#
# CONSTANTS
.equ	SPACE, ' ' 			# ' '
.equ	TILDE, '~' 			# '~'

# stack representation
.equ	ST_BUFFER_LEN, 16		# length of buffer (1*8 + 8)
.equ	ST_OBUFFER, 24			# output buffer (2*8 + 8)
.equ	ST_IBUFFER, 32			# input buffer (3*8 + 8)

.type	toChars, @function
	.global	toChars
toChars:
	push	%rbp			# save stack for function return
	mov	%rsp, %rbp
	
	# Initialize
	mov	ST_IBUFFER(%rbp), %rax
	mov	ST_OBUFFER(%rbp), %rdx
	mov	ST_BUFFER_LEN(%rbp), %rbx
	xor	%rdi,%rdi
	xor	%rsi,%rsi

	cmp	$0, %rbx		# if length is 0, we're done
	je	exit

convertLoop:
	xor	%rcx,%rcx		# clear %rcx
	mov	(%rax,%rdi,1), %cl	# get current byte from buffer
	cmpb	$SPACE, %cl		# only convert printable letters
	jl	unprintable
	cmpb	$TILDE, %cl
	jg 	unprintable
	mov	%cl, (%rdx,%rdi,1)	# copy to output buffer
next_byte:
	inc	%rdi			# move to next byte
	cmp	%rdi, %rbx		# all chacters converted?
	jne	convertLoop
exit:
	mov	%rbp, %rsp		# restore stack for function return
	pop	%rbp
	ret	
unprintable:
	movb	$SPACE, (%rax,%rdi,1)	# print a ' '
	jmp 	next_byte
