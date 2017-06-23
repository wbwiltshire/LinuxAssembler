#Purpose: Print out the Hello World message to STDOUT
#
# Written for Linux x86_64
# VARIABLES: The registers have the following users
#
# %r prefix means 64bit registers
#
# %rax has the system call
# %rdi has the file handle
# %rsi has the message address
# %rdx has the number of bytes to output 
#
# CONSTANTS
.equ	STDOUT, 1
.equ	SYS_WRITE, 1
.equ	SYS_EXIT, 60

.data
msg:
.ascii  "Hello, world!\n"
	len =   . - msg

.text
	.global	_start

_start:
	mov	$SYS_WRITE, %rax	# Move value 1 into reg. ax for 'write' system call
	mov	$STDOUT, %rdi		# File handle is 1 for stdout
	mov	$msg, %rsi		# Move address of string to output
	mov	$len, %rdx		# Numbe of bytes to output
	syscall				# Make system call

        # Return exit(0)
	mov	$SYS_EXIT, %rax		# System call 60 is exit
	mov	$0, %rdi		# Return code of 0
	syscall				#Make system call
