# FUNCTION: readFile
#
# PURPOSE: Read the contents of a file into memory
#
# CALLING CONVENTION: Linux X86_64 ABI
# %r prefix for 64bit registers
#
# INPUT:
#   %rdi - call parameter 1 (integer to print)

# OUTPUT:
#	None
#
# VARIABLES: The registers have the following uses
#
# %rax - division of integer
# %rbx - length of the buffer
# %rcx - digit count
# %rdx - division of integer
# %rdi - divisor
#
# CONSTANTS

.text
.include "macros.inc"
.type   readFile, @function
        .global readFile

readFile:
        push    %rbp            # save stack for function return
        mov     %rsp, %rbp

exit:
        mov %rbp, %rsp          # restore stack for function return
        pop %rbp
        ret
