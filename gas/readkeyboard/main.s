#Purpose: Read charactes from the keyboard
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
.equ	SYS_READ, 0
.equ	SYS_WRITE, 1
.equ	SYS_EXIT, 60

# DATA SECTION
.data
.equ	BUFFER_SIZE, 240
kbdBuffer: 
.rep BUFFER_SIZE
	.quad	0
.endr
newLine:
.ascii	"\n"
prompt:
.ascii	"Enter you text: "
	lenPrompt= . - prompt
debugMsg:
.ascii	"Debug reached!\n"
	lenDebugMsg	= . - debugMsg

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

	# Display prompt
	SYSPRINT $prompt, $lenPrompt

	# Read Input
	mov	$SYS_READ, %rax		# read system call
	mov	$STDIN, %rdi		# file handle for stdin
	mov	$kbdBuffer, %rsi		# move address of string to output
	mov	$BUFFER_SIZE, %rdx	# numbe of bytes to output
	syscall				# make system call

	mov	%rax, %rcx		# count of characters read in %rax
	
	# Print Input
	SYSPRINT $kbdBuffer, %rcx
	SYSPRINT $newLine, $1

exit:
        # Return exit(0)
	SYSEXIT $0
