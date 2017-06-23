# FUNCTION: <function>
#
# PURPOSE: Template for assembler function 
#
# CALLING CONVENTION: Linux X86_64 ABI
# %r prefix for 64bit registers
#
# INPUT:
#   %rdi - call parameter 1
#   %rsi - call parameter 2
#   %rdx - call parameter 3
#   %rcx - call parameter 4
#   %r8 - call parameter 5
#   %r9 - call parameter 6
#   Note: additional parameters passed on stack

# OUTPUT:
#   %rax - return value  1
#   %rdx - return value  2
#
# VARIABLES: The registers have the following uses
#
# %rbx - length of the buffer
# %cl  - current byte being copied
# %rdx - beginning of the buffer
# %rdi - current buffer offset
#
# CONSTANTS

.type   function, @function
        .global function

function: 
        push    %rbp              # save stack for function return
        mov     %rsp, %rbp

        # Initialize
        
exit:
        mov %rbp, %rsp            # restore stack for function return
        pop %rbp
        ret
