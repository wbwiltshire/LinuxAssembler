#Purpose: Print out the command line arguments
#
# Written for Linux x86_64
# VARIABLES: The registers have the following users
#
# %r prefix means 64bit registers
#
# CONSTANTS

# BUFFER SECTION
.bss
.equ	BUFFER_SIZE, 240
.lcomm	BUFFER_DATA, BUFFER_SIZE

.data
.equ    ARG_COUNT, 3
newLine:
.ascii  "\n"
argC:	
	.quad	0
argCStr:	
	.quad	0
	.ascii	"\0\n"	
	lenArgCStr = . - argCStr
argPtrs:
.rep	ARG_COUNT	# table of argument addresses
	.quad	0	
.endr
argLens:
.rep	ARG_COUNT	# table of argument lengths
	.quad	0
.endr
usage:
	.ascii	"Usage: showargs <arg1> <arg2>\n"	
	lenUsage = . - usage
debugMsg:
.ascii  "Debug reached!\n"
        lenDebugMsg     = . - debugMsg

#CODE SECTION
.text	

# CONSTANTS
.equ    STDOUT, 1
.equ    SYS_WRITE, 1
.equ    SYS_EXIT, 60
.equ    MAX_STR_LEN, 256

# MACROS
.macro SYSEXIT exitCd
        mov     $SYS_EXIT, %rax         # system call 60 is exit
        xor     \exitCd, %rdi           # set return code
        syscall                         # make system call
.endm
.macro SYSPRINT sMsg, sLength
        mov     $SYS_WRITE, %rax        # move value 1 into reg. ax for 'write' system call
        mov     $STDOUT, %rdi           # file handle is 1 for stdout
        mov     \sMsg, %rsi             # move address of string to output
        mov     \sLength, %rdx          # numbe of bytes to output
        syscall                         # make system call
.endm
.macro SYSDEBUG sMsg, sLength
	push	%rax			# save all registers
	push	%rbx
	push	%rcx
	push	%rdx
	push	%rbp
	push	%rsi
	push	%rdi
        mov     $SYS_WRITE, %rax        # move value 1 into reg. ax for 'write' system call
        mov     $STDOUT, %rdi           # file handle is 1 for stdout
        mov     \sMsg, %rsi             # move address of string to output
        mov     \sLength, %rdx          # numbe of bytes to output
        syscall                         # make system call
	pop	%rdi
	pop	%rsi
	pop	%rbp
	pop	%rdx
	pop	%rcx
	pop	%rbx
	pop	%rax			# save all registers
.endm

# Main program
	.global	_start
_start:
	# Initialize
	mov %rsp, %rbp		# save stack pointer
	pop	%rcx		# get argument count
	cmp	$ARG_COUNT,%rcx # compare to max arguments
	jg	error

	# Print the argument count
	mov	%rcx, %rax 	# get the argument count
	mov	%rcx, (argC)	# store argument count
	add	$48, %rax	# adjust to ascii
	mov	%rax, (argCStr)	# store argument count
	mov	$argC, %rdi	# set the buffer address for printing
	SYSPRINT $argCStr, $lenArgCStr

	# Save the the arguments to a table
	mov	(argC),%rcx	# retrieve argument count from stack
	xor	%rdx, %rdx	# setup a loop counter
saveArgs:
	pop	%rax		# pop argument address into %rax
	mov	%rax, argPtrs(,%rdx,8)	# save argument address in table
	inc	%rdx
	cmp	%rcx, %rdx	
	jb	saveArgs	# continue until all args processed

	# Save the the argument lengths to a table
	xor	%rax, %rax		# search for null string terminator '\0'
	xor	%rbx, %rbx		# counter for loop

getLengths:
	xor	%rcx, %rcx		# set max string len
	not	%rcx			
	mov	argPtrs(,%rbx,8), %rdi	# get argument address
	#SYSDEBUG $debugMsg, $lenDebugMsg
	cld				# clear the direction flag
	repne	scasb			# scan string byte by byte
	jnz	error			# jump if we don't find null terminator
	#movb   $10,-1(,%rdi,1)		# add line feed on end?	
	not 	%rcx			# compute the length
	dec	%rcx
	mov	%rcx, argLens(,%rbx,8)	# store length in table
	inc	%rbx
	cmp	(argC), %rbx		# compare to number of args
	jne	getLengths		# continue until all processed

	xor	%rbx, %rbx		# counter for loop
printArgs:
	mov	argPtrs(,%rbx,8), %rcx
	mov	argLens(,%rbx,8), %rdx
	push	%rbx
	SYSPRINT %rcx, %rdx
	SYSPRINT $newLine, $1
	pop	%rbx
	inc	%rbx
	cmp	(argC), %rbx		# compare to number of args
	jne	printArgs		# continue until all processed

exit:
        # Return exit(0)
	SYSEXIT	$0		# return to OS

error:  #Print usage
	SYSPRINT $usage, $lenUsage
	jmp exit
