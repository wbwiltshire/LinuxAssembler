#Purpose: Convert an input file to all UPPER case and write to output file.
#
# VARIABLES: The registers have the following users
#
# Written for Linux x86_64
# %r prefix means 64 bit registers
# %e prefix means 32 bit registers
#
# Linux x86_64 system calls: http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
#
# CONSTANTS
.equ	STDIN, 0
.equ	STDOUT, 1
.equ	STDERR, 2
.equ	SYS_OPEN, 2
.equ	SYS_CLOSE, 3
.equ	SYS_READ, 0
.equ	SYS_WRITE, 1
.equ	SYS_EXIT, 60
.equ	O_RDONLY, 0
.equ	O_CREAT_WRONLY_TRUNC, 0x0041
.equ	O_CREAT_RDWR_TRUNC, 0x0242
.equ	RDONLY_PERMS, 0444	# in octal
#.equ	RDWR_PERMS, 0x01b4
.equ	RDWR_PERMS, 0660	# in octal
.equ	EOF, 0
.equ	NBR_ARGUMENTS, 2
.equ	BUFFER_SIZE, 512

# BUFFER SECTION
.bss
.equ	BUFFER_SIZE, 512
.lcomm	BUFFER_DATA, BUFFER_SIZE

# DATA SECTION
.data
.equ	ARG_COUNT, 3
inFileFD:
	.quad	0
outFileFD:
	.quad	0
argC:
        .quad   0
argPtrs:
.rep    ARG_COUNT       # table of argument addresses
        .quad   0
.endr
argLens:
.rep    ARG_COUNT       # table of argument lengths
        .quad   0
.endr
argCStr:
        .quad   0
        .ascii  "\0\n"
        lenArgCStr = . - argCStr
newLine:
.ascii	"\n"
msg:
.ascii	"Conversion to uppercase complete!\n"
	lenMsg	= . - msg
noArgsMsg:
.ascii	"Usage: toupper <infile> <outfile>\n"
	lenNoArgsMsg	= . - noArgsMsg
debugMsg:
.ascii	"Debug reached!\n"
	lenDebugMsg	= . - debugMsg
fileErrorMsg:
.ascii	"File error: (-"
errorCD: .quad	0
.ascii	")\n"
	lenFileErrorMsg	= . - fileErrorMsg

# CODE SECTION
.text
# CONSTANTS

# MACROS
.macro SYSEXIT exitCd
	mov	$SYS_EXIT, %rax		# system call 60 is exit
	xor	\exitCd, %rdi		# set return code 
	syscall				# make system call
.endm
.macro SYSPRINT sMsg, sLength
	mov	$SYS_WRITE, %rax	# move value 1 into reg. ax for 'write' system call
	mov	$STDOUT, %rdi		# file handle is 1 for stdout
	mov	\sMsg, %rsi		# move address of string to output
	mov	\sLength, %rdx		# numbe of bytes to output
	syscall				# make system call
.endm
.macro SYSDEBUG sMsg, sLength
        push    %rax                    # save all registers
        push    %rbx
        push    %rcx
        push    %rdx
        push    %rbp
        push    %rsi
        push    %rdi
        mov     $SYS_WRITE, %rax        # move value 1 into reg. ax for 'write' system call
        mov     $STDOUT, %rdi           # file handle is 1 for stdout
        mov     \sMsg, %rsi             # move address of string to output
        mov     \sLength, %rdx          # numbe of bytes to output
        syscall                         # make system call
        mov     $SYS_WRITE, %rax        
        mov     $STDOUT, %rdi          
        mov     $newLine, %rsi        
        mov     $1, %rdx    
        syscall                     
        pop     %rdi
        pop     %rsi
        pop     %rbp
        pop     %rdx
        pop     %rcx
        pop     %rbx
        pop     %rax                    # save all registers
.endm

# Start of main program
	.global	_start

_start:
	# Initialiize
	mov	%rsp, %rbp		# save stack pointer
        pop     %rcx           		# get argument count
        cmp     $ARG_COUNT,%rcx 	# compare to max arguments
	je	saveArgCount
	jmp	usage

        # Save the the arguments to a table
saveArgCount:
        mov     %rcx, (argC)   		# save argument count 
        xor     %rdx, %rdx      	# setup a loop counter
saveArgs:
        pop     %rax            	# pop argument address into %rax
        mov     %rax, argPtrs(,%rdx,8)  # save argument address in table
        inc     %rdx
        cmp     %rcx, %rdx
        jb      saveArgs        	# continue until all args processed

        # Save the the argument lengths to a table
        xor     %rax, %rax              # search for null string terminator '\0'
        xor     %rbx, %rbx              # counter for loop
getLengths:
        xor     %rcx, %rcx              # set max string len
        not     %rcx
        mov     argPtrs(,%rbx,8), %rdi  # get argument address
        #SYSDEBUG $debugMsg, $lenDebugMsg
        cld                             # clear the direction flag
        repne   scasb                   # scan string byte by byte
        jnz     usage                   # jump if we don't find null terminator
        not     %rcx                    # compute the length
        dec     %rcx
        mov     %rcx, argLens(,%rbx,8)  # store length in table
        inc     %rbx
        cmp     (argC), %rbx            # compare to number of args
        jne     getLengths              # continue until all processed

	# Used for debugging
printArgs: 
	mov	$1, %rbx
	mov	argPtrs(,%rbx,8), %rcx
	mov	argLens(,%rbx,8), %rdx
	SYSDEBUG %rcx, %rdx
	mov	$2, %rbx
	mov	argPtrs(,%rbx,8), %rcx
	mov	argLens(,%rbx,8), %rdx
	SYSDEBUG %rcx, %rdx

openFiles:
	# Open input file
 	mov 	$SYS_OPEN, %rax		# open syscall
	mov	$1,%rcx
	mov	argPtrs(,%rcx,8), %rdi	# rove address of input file name to %rbx
	mov	$O_RDONLY, %rsi		# set to read only
	mov	$RDONLY_PERMS, %rdx	# doesn't really matter for reading
	syscall				# make system call
	cmp	$0, %rax
	jl	fileError
	mov	%rax, (inFileFD)	# save file handle

	# Open output file
 	mov 	$SYS_OPEN, %rax		# open syscall
	mov	$2,%rcx
	mov	argPtrs(,%rcx,8), %rdi	# rove address of input file name to %rbx
	mov	$O_CREAT_RDWR_TRUNC, %rsi	# empty file and set to write only
	mov	$RDWR_PERMS, %rdx	# set file permissions
	syscall				# make system call
	cmp	$0, %rax
	jl	fileError
	mov	%rax, (outFileFD)	# save file handle

readLoop:
	# Start Read Loop
	mov	$SYS_READ, %rax		# read syscall
	mov	(inFileFD), %rdi	# set file handle
	mov	$BUFFER_DATA, %rsi	# set buffer address and size
	mov	$BUFFER_SIZE, %rdx	
	syscall				# make system call
	cmp	$EOF, %rax		# check if end of file
	jle	endLoop

	# Conver to upper case
	push	$BUFFER_DATA		# set buffer on stack for call
	push 	%rax			# set bytes read on stack for call
	call 	toUpper
	pop	%rax			# get the size back
	add	$8, %rsp		# remove buffer address from stack

	# Write buffer to output
	mov	%rax, %rdx		# set buffer size
	mov	$SYS_WRITE, %rax	# write syscall
	mov	(outFileFD), %rdi	# set file handle
	mov	$BUFFER_DATA, %rsi	# set buffer address
	syscall				# make system call
	#SYSPRINT $debugMsg, $lenDebugMsg

	# Continue with loop
	jmp	readLoop

endLoop:
	# Close files			# No error checking needed on close
	mov	$SYS_CLOSE, %rax	# close syscall
	mov 	(outFileFD), %rdi	# file handle
	syscall				# make system call
	mov	$SYS_CLOSE, %rax	# close syscall
	mov 	(inFileFD), %rdi 	# file handle
	syscall				# make system call

	# Print completion message
	SYSPRINT $msg, $lenMsg

exit:
        # Return exit(0)
	SYSEXIT $0
usage:
	SYSPRINT $noArgsMsg, $lenNoArgsMsg
	jmp	exit
	# %rax has file error code
fileError:
	not	%rax			# make positive
	add	$48, %rax		# adjust for ascii
	mov	%rax, (errorCD)
	SYSPRINT $fileErrorMsg, $lenFileErrorMsg
	jmp	exit

