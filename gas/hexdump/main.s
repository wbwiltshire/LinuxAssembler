# Prints out contents of a file in hex format
#
# VARIABLES: The registers have the following users
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

# DATA SECTION
.data
.equ	ARG_COUNT, 2
inFileFD:
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
startTime:
startSecs:
        .quad 0
startMSecs:
        .quad 0
endTime:
endSecs:
        .quad 0
endMSecs:
        .quad 0
lineAddress:
		.quad 0
valString: 
	.asciz	"00000000"
elapsedMsg:
        .ascii  "Elapsed time(us): "
        lenElapsedMsg =   . - elapsedMsg
initLine: 
	.ascii	"0000000  0000 0000 0000 0000 0000 0000 0000 0000    "
	.ascii	"                \n"
dumpLine: 
	.ascii	"0000000  0000 0000 0000 0000 0000 0000 0000 0000    "
dumpChars:
	.ascii	"                \n"
	lenDumpLine = . - dumpLine
newLine:
.ascii	"\n"
usageMsg:
.ascii	"Usage: hexdump <infile> \n"
	lenUsageMsg	= . - usageMsg
fileErrorMsg:
.ascii	"File error: (-"
errorCD: .quad	0
.ascii	")\n"
	lenFileErrorMsg	= . - fileErrorMsg
debugMsg:
.ascii	"Debug reached!\n"
	lenDebugMsg	= . - debugMsg

# CODE SECTION
.text
# CONSTANTS

.include "macros.inc"

# Start of main program
	.global	_start

_start:
	# Initialiize
	mov	%rsp, %rbp		# save stack pointer
	# Capture start time
	mov     $startTime, %rdi                # pointer to timeval structure
	mov     $0, %rsi                # pointer to timezone structure (should be null)
	mov     $SYS_GET_TOD, %rax      # sys/gettimeofday system call
	syscall                         # Make system call
    #mov    %rax, %rax              # %rax contains 0 (success) or -1 (fail)

    # Grab command line args
	pop     %rcx           		# get argument count
	cmp     $ARG_COUNT,%rcx 	# compare to max arguments
	je		saveArgCount
	jmp		usage

saveArgCount:
	mov     %rcx, (argC)   		# save argument count 

	# Save the the argument pointers to a table
	mov		%rsp, %rsi			# set argument pointers source to stack 
	lea		argPtrs, %rdi		# set destination
	cld
	rep		movsq				# move the addresses

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
printFirstArg: 
	mov		$1, %rbx
	mov		argPtrs(,%rbx,8), %rcx
	mov		argLens(,%rbx,8), %rdx
	SYSDEBUG %rcx, %rdx

openFiles:
	# Open input file
 	mov 	$SYS_OPEN, %rax		# open syscall
	mov		$1,%rcx
	mov		argPtrs(,%rcx,8), %rdi	# move address of input file name to %rbx
	mov		$O_RDONLY, %rsi		# set to read only
	mov		$RDONLY_PERMS, %rdx	# doesn't really matter for reading
	syscall				# make system call
	cmp		$0, %rax
	jl		fileError
	mov		%rax, (inFileFD)	# save file handle

readLoop:
	# Start Read Loop
	mov		$SYS_READ, %rax		# read syscall
	mov		(inFileFD), %rdi	# set file handle
	mov		$BUFFER_DATA, %rsi	# set buffer address and size
	mov		$BUFFER_SIZE, %rdx	
	syscall						# make system call
	cmp		$EOF, %rax			# check if end of file
	jle		endLoop
	mov		$BUFFER_DATA, %rcx	# get address of buffer data 

nextLine:
	push	%rax			# save number bytes read
	push 	%rcx			# save read data buffer

	# Convert Address part to hex string (RegString)
	mov		(lineAddress), %rax
	push	%rax			# set line address value on stack for call
	mov		$valString, %rax
	push	%rax			# set output buffer on stack for call

	call 	print32			# value, output
	
	# Copy regString to Address part (only last 7 hex digits)
	mov		$valString, %rax	# get source address for call
	add		$1, %rax		# offset by 1 byte
	push	%rax			# set source address for call 
	push	$dumpLine 		# set destination address for call
	mov		$7, %rax
	push	%rax			# set length to copy for call 
	call	memCopy			# source, destination, length
	add		$24, %rsp		# cleanup memcopy stack
	
	# Cleanup printReg stack
	pop		%r10			# cleanup output buffer from stack
	pop		%r10			# restore line address from stack
	pop		%rcx			# restore read data buffer
	pop		%rax			# restore number of bytes read
	
	# Update output line address
	add	$16, %r10
	mov	%r10, (lineAddress)
	
	# print Hex part in hex
	push	%rax			# save number bytes read
	push	%rcx			# set input buffer on stack for call
	mov		$dumpLine, %rax	# set output buffer address
	add		$9,	%rax		# move start position past address area
	push	%rax			# set output buffer on stack for call

	mov		$16, %rax
	push 	%rax			# set bytes to convert
	call 	toHex			# input, output, length

	# Print ASCII part in ASCII
	pop		%rax			# reset bytes to convert
	pop		%rbx			# reset output buffer pointer
	push	$dumpChars		# set output buffer on stack for call
	push 	%rax			# set bytes to convert
	call 	toChars
	add		$16, %rsp		# cleanup stack 

	# Write output and then initalize output line for next iteration
	SYSPRINT $dumpLine, $lenDumpLine
	push	$initLine 		# init buffer
	push	$dumpLine 		# output buffer
	push	$lenDumpLine	# length of buffer
	call	memCopy
	add	$24, %rsp		# cleanup stack
	
	pop	%rcx			# retrieve read buffer
	add	$16, %rcx		# adjust pointer to input buffer for bytes read
	pop	%rax			# retrieve number of bytes read
	sub	$16, %rax		# adjust remaining bytes to process
	cmp	$EOF, %rax		# check if end of buffer
	jg	nextLine

	# Continue with loop
	jmp	readLoop

endLoop:
	# Close files			# No error checking needed on close
	mov	$SYS_CLOSE, %rax	# close syscall
	mov 	(inFileFD), %rdi 	# file handle
	syscall				# make system call

exit:
	# Capture end time
	SYSPRINT $newLine, $1
	SYSPRINT $elapsedMsg, $lenElapsedMsg
	mov     $endTime, %rdi          # pointer to timeval structure
	mov     $0, %rsi                # pointer to timezone structure (should be null)
	mov     $SYS_GET_TOD, %rax      # sys/gettimeofday system call
	syscall                         # Make system call
	#mov    %rax, %rax              # %rax contains 0 (success) or -1 (fail)
	mov     endSecs, %rax           # Move seconds for substract
    sub     startSecs, %rax         # Difference is elapsed time in usecs
	mov     $1000000, %rcx          # Adjust for 1M microseconds/second
	mul     %rcx                    # mull works by rcx * rax 
					# stores result in rdx:rax
        mov     endMSecs, %rdi          # Move for substract
        sub     startMSecs, %rdi        # Difference is elapsed time in usecs
        add	%rax, %rdi              # Add in the difference in seconds
        call    printElapsed            # %rdi has the elapsed time (p1)
        SYSPRINT $newLine, $1

        # Return exit(0)
	SYSEXIT $0
usage:
	SYSPRINT $usageMsg, $lenUsageMsg
	jmp	exit
	# %rax has file error code
fileError:
	not	%rax			# make positive
	add	$48, %rax		# adjust for ascii
	mov	%rax, (errorCD)
	SYSPRINT $fileErrorMsg, $lenFileErrorMsg
	jmp	exit
