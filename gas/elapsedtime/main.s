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
.equ	SYS_GET_TOD, 96

.data
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
msg:
	.ascii  "Elapsed time(ms): "
	len =   . - msg
newLine:
	.ascii "\n"

.text
.include "macros.inc"
	.global	_start

_start:
	# Call system GetTimeOfDay
        mov	$startTime, %rdi		# pointer to timeval structure
        mov	$0, %rsi		# pointer to timezone structure (should be null)
	mov	$SYS_GET_TOD, %rax	# sys/gettimeofday system call
	syscall				# Make system call
	#mov	%rax, %rax		# %rax contains 0 (success) or -1 (fail)

	SYSPRINT $msg, $len

	# Call system GetTimeOfDay
        mov	$endTime, %rdi		# pointer to timeval structure
        mov	$0, %rsi		# pointer to timezone structure (should be null)
	mov	$SYS_GET_TOD, %rax	# sys/gettimeofday system call
	syscall				# Make system call
	#mov	%rax, %rax		# %rax contains 0 (success) or -1 (fail)
        mov     endSecs, %rax           # Move seconds for substract
        sub     startSecs, %rax         # Difference is elapsed time in usecs
        mov     $1000000, %rcx          # Adjust for 1M microseconds/second
        mul     %rcx                    # mul works by rcx * rax
                                        # stores result in rdx:rax (hi/lo)
	mov 	endMSecs, %rdi		# Move for substract
        sub     startMSecs, %rdi        # Difference is elapsed time in usecs
	add	%rax, %rdi		# Add in the difference in seconds
        call	printElapsed		# %rdi has the elapsed time (p1)
	SYSPRINT $newLine, $1

        # Return exit(0)
	SYSEXIT	$0
