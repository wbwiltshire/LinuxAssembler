#Purpose: Print out the command line arguments
#
# Written for Linux x86_64
# VARIABLES: The registers have the following users
#
# %r prefix means 64bit registers
#
# %rdi - argument count
# %rsi - address of argument values list
#
# CONSTANTS

	.global	main
.data
argc:	.quad	0
	.byte	0x00;	
format:
	.asciz	"%s\n"
.text	

main:
	# Print the argument count
	push	%rdi		# save registers used by puts
	push	%rsi		
	sub	$8, %rsp	# adjust stack for return
	add	$48, %rdi	# adjust to ascii
	mov	%rdi, (argc)	# store argument count in a buffer
	mov	$argc, %rdi	# set the buffer address for printing
	call	puts		# print it

	add 	$8, %rsp	# restore stack pointer
	pop	%rsi
	pop	%rdi

	# Print the arguments 
args:
	push	%rdi		# save registers used by puts
	push	%rsi		
	sub	$8, %rsp	# adjust stack for return
	mov	(%rsi), %rdi	# grab an argument 
	call	puts		# print it

	add 	$8, %rsp	# restore stack pointer
	pop	%rsi
	pop	%rdi

	add 	$8, %rsi	# point to next arguement
	dec	%rdi		# decrement argument count
	jnz	args

        # Return exit(0)
	xor	%rax,%rax	# return 0 on exit
	ret			# return to OS
