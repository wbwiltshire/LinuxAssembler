#Purpose: Template for Linux X86_64 assembly program
#
# Written for Linux x86_64 ABI
# VARIABLES: The registers have the following uses
#
# %r prefix for 64bit registers
#
# Function / System Calls
# %rax - return value  1
# %rdx - return value  2
#
# %rdi - call parameter 1
# %rsi - call parameter 2
# %rdx - call parameter 3
# %rcx - call parameter 4
# %r8 - call parameter 5
# %r9 - call parameter 6
# Note: additional parameters passed on stack
#
# Stack on program entry with command line parameters
#
# <arg n
# .....
# <arg 2>
# <arg 1>
# <arg count>   <---%rsp
#
#####################################################
# CONSTANTS
.equ    STDOUT, 1
.equ    SYS_WRITE, 1
.equ    SYS_EXIT, 60
.equ    MAX_ARGS, 2
.equ    MAX_STR_LEN, 255

.bss

.data
argC:
        .quad   0
argPtrs:
.rep    MAX_ARGS        # table of argument addresses
        .quad   0
.endr
argLens:
.rep    MAX_ARGS        # table of argument lengths
        .quad   0
.endr
msg:
.ascii  "template completed successfully!\n"
        len =   . - msg
usageMsg:
.ascii  "Usage: program <arg1> <args2>\n"
        lenUsageMsg =   . - usageMsg
newLine:
.ascii  "\n"

.text
        .global _start

.include "macros.inc"

_start:
        # Initialize
        mov %rsp, %rbp    # save stack pointer

        # Process command line
        jmp commandLine
main:
        mov   $1, %rdi    # parameter 1
        mov   $2, %rsi    # parameter 2
        mov   $3, %rdx    # parameter 3
        mov   $4, %rcx    # parameter 4
        mov   $5, %r8     # parameter 5
        mov   $6, %r9     # parameter 6
        call function     # return values in %rax and %rdx

        SYSPRINT $msg, $len

exit:
        # Return exit(0)
        SYSEXIT $0        # return 0 to OS
        
        # Process command line arguments
commandLine:
pop     %rcx                            # get argument count
        cmp     $MAX_ARGS, %rcx         # compare to max arguments
        je      saveArgCount
        jmp     usage

        # Save the the arguments to a table
saveArgCount:
        mov     %rcx, (argC)            # save argument count
        xor     %rdx, %rdx              # setup a loop counter
saveArgs:
        pop     %rax                    # pop argument address into %rax
        mov     %rax, argPtrs(,%rdx,8)  # save argument address in table
        inc     %rdx
        cmp     %rcx, %rdx
        jb      saveArgs                # continue until all args processed

        # Save the the argument lengths to a table
        xor     %rax, %rax              # search for null string terminator '\0'
        xor     %rdx, %rdx              # counter for loop
getLengths:
        mov     $MAX_STR_LEN, %rcx      # set max string len
        mov     argPtrs(,%rdx,8), %rdi  # get argument address
        cld                             # clear the direction flag
        repne   scasb                   # scan starting at %rdi for %rcx bytes
					# looking for %al
        jnz     usage                   # jump if we don't find null terminator
        mov	$MAX_STR_LEN - 1, %rbx
	SUB	%rcx, %rbx              # compute the length
        mov     %rbx, argLens(,%rdx,8)  # store length in table
        inc     %rdx
        cmp     (argC), %rdx            # compare to number of args
        jne     getLengths              # continue until all processed

        # Used for debugging
printArgs:
        mov     $0, %rsi
        mov     argPtrs(,%rsi,8), %rbx
        mov     argLens(,%rsi,8), %rcx
        SYSDEBUG %rbx, %rcx
        mov     $1, %rsi
        mov     argPtrs(,%rsi,8), %rbx
        mov     argLens(,%rsi,8), %rcx
        SYSDEBUG %rbx, %rcx

        jmp main    # return to main program
usage:
        SYSPRINT $usageMsg, $lenUsageMsg
        jmp   exit
