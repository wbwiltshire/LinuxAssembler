# Reference impelementation for X86_64 assembler on Linus
# using GNU Assembler (gas) and AT&T syntax
#
# Written for Linux x86_64
# %r prefix means 64 bit registers
# %e prefix means 32 bit registers
#
# Linux x86_64 system calls: http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
#
# BUFFER SECTION
.bss
.equ	BUFFER_SIZE, 512
.lcomm	BUFFER_DATA, BUFFER_SIZE

# CONSTANTS
.equ	STDIN, 0
.equ	STDOUT, 1
.equ	STDERR, 2
.equ	SYS_OPEN, 2
.equ	SYS_CLOSE, 3
.equ	SYS_READ, 0
.equ	SYS_WRITE, 1
.equ	SYS_EXIT, 60
.equ	SYS_GET_TOD, 96
.equ	O_RDONLY, 0
.equ	RDONLY_PERMS, 0444	# in octal
.equ	EOF, 0
.equ	SPACE, ' '
.equ	ARG_COUNT, 2

# CODE SECTION
.text
# MACROS
.include "macros.inc"

#### Start of main program ###
	.global	_start

_start:
	# Initialiize
	mov		%rsp, %rbp				# save stack pointer
	
	# Capture start time
	mov     $startTime, %rdi        # pointer to timeval structure
	mov     $0, %rsi                # pointer to timezone structure (should be null)
	mov     $SYS_GET_TOD, %rax      # sys/gettimeofday system call
	syscall                         # Make system call
	#mov    %rax, %rax              # %rax contains 0 (success) or -1 (fail)

	# Process command line arguments
	push	$argC					# pass location to store argument count
	push	$argPtrs				# pass location to store argument points
	push	$argLens				# pass location to store argument lengths
	call	getArgs
	add		$24, %rsp				# restore the stack
	
	mov		argC, %rax
	cmp     $ARG_COUNT,%rax 		# compare to expected argument count
	je		examples				# continue, if there were 2 paramaters (program name  + filename)
	jmp		usage

examples:
	# Examples of moving data and address modes
	.include "addressingModes.inc"
	
	# Examples of different jumps and compares
	.include	"compareAndJump.inc"
	
	# Example of strings
	.include	"stringStuff.inc"
	
	# Examples of math instructions (addition, subtraction, multiplication, and division)
	.include "mathinstructions.inc"
	
	# Example of a loop instruction
	#   Note: Research indicates that loop instruction executes very slowly on 80486 and above
	#         and should no longer be used 
	
	# Call puts "C" library function
	mov     $cMessage, %rdi         # First integer (or pointer) parameter in %rdi
    call    puts 
	
	# Call printf "C" library function
	# Note: printf may destroy rax, and rcx, so we'll save them before the call
	push	%rax
	push	%rcx
	mov		$cMessage2, %rdi        # set 1st parameter (format string)
	mov		$cParm2, %rsi			# set 2st parameter (first variable)
	xor		%rax, %rax				# because printf is varargs
    call    printf 
	pop		%rcx
	pop		%rax
	
readFile:
	.include "readFile.inc"
	SYSPRINT $newLine, $1
	SYSPRINT $readFileMsg, $lenrfm
	SYSPRINT $newLine, $1
	
exit:
	# Capture end time
	SYSPRINT $newLine, $1
	SYSPRINT $elapsedMsg, $lenElapsedMsg
	mov		$endTime, %rdi          # pointer to timeval structure
	mov		$0, %rsi                # pointer to timezone structure (should be null)
	mov     $SYS_GET_TOD, %rax      # sys/gettimeofday system call
	syscall                         # Make system call
	#mov    %rax, %rax              # %rax contains 0 (success) or -1 (fail)
	mov     endSecs, %rax           # Move seconds for substract
    sub     startSecs, %rax         # Difference is elapsed time in usecs
	mov     $1000000, %rcx          # Adjust for 1M microseconds/second
	mul     %rcx                    # mul will multiplie rcx * rax 			
									# result in rax (least significant) and rdx
									
	mov     endMSecs, %rdi          # Move for substract
	sub     startMSecs, %rdi        # Difference is elapsed time in usecs
	add		%rax, %rdi              # Add in the difference in seconds
	call    printElapsed            # %r10 has the elapsed time (p1)
    SYSPRINT $newLine, $1

    # Return exit(0)
	SYSEXIT $0
usage:
	SYSPRINT $usageMsg, $lenUsageMsg
	jmp	exit
	# %rax has file error code
fileError:
	not		%rax					# make positive
	add		$48, %rax				# adjust for ascii
	mov		%rax, (errorCD)
	SYSPRINT $fileErrorMsg, $lenFileErrorMsg
	jmp		exit

# 	Far jump for conpareAndJump
.org		0x9000
farJump:
	SYSPRINT $farJumpMsg, $fjlen
	jmp		nearConditional

# BUFFER SECTION
.bss
	#local storage allocated at runtime
	.lcomm		destination, 11
	.lcomm		destinationRep, 11
	.lcomm		destinationStos, 11
	
# DATA SECTION
.data
inFileFD:			.quad	0
argC:				.quad	0
argPtrs:	# table of argument addresses 
	.rep	ARG_COUNT       .quad   0
	.endr
argLens:	# table of argument lengths
	.rep    ARG_COUNT       .quad   0
	.endr
startTime:
	startSecs:		.quad 	0
	startMSecs:		.quad 	0
endTime:
	endSecs:		.quad 	0
	endMSecs:		.quad 	0
lineAddress:		.quad	0
valString:			.asciz	"00000000"
usageMsg:			.ascii  "Usage: reference <infile> \n"
	lenUsageMsg     = . - usageMsg
elapsedMsg:			.ascii  "Elapsed time(us): "
	lenElapsedMsg =   . - elapsedMsg
readFileMsg:		.ascii  "Read file."
	lenrfm =   		. - readFileMsg
newLine:			.ascii	"\n"
fileErrorMsg:		.ascii	"File error: (-"
errorCD:			.quad	0
					.ascii	")\n"
	lenFileErrorMsg	= . - fileErrorMsg
debugMsg:			.ascii	"Debug reached!\n"
	lenDebugMsg	= . - debugMsg
cMessage:			.asciz	"\nPrinted from C library!\n"
cMessage2:			.asciz	"Hello %s!\n"
cParm2:				.asciz	"World"

	# Data for Addressing Modes
.equ	FOUR_PLUS_FOUR,	4 + 4
oneb:		.byte		1			# 1 byte
onei:		.int		1			# 2 bytes (could also be .word)
onel:		.long		1			# 4 bytes
oneq:		.quad		1			# 8 bytes
onea:		.ascii		"1"			# string
			.byte		0					
oneaz:		.asciz		"1"			# null terminated string
listb:		.byte		1, 2, 3		# 3 bytes
listi:		.int		1, 2, 3 	# 6 bytes
listl:		.long		1, 2, 3		# 12 bytes
listq:		.quad		1, 2, 3		# 24 bytes	

	# Data for compareAndJump
dontrun:	.asciz		"Oops!\n"	# shouldn't run message
	drlen	= . - dontrun
farJumpMsg:	.asciz		"Jumped far!\n"	# shouldn't run message
	fjlen	= . - farJumpMsg
	# Data for stringStuff
sourceString:		.asciz		"012345689"		# string
	