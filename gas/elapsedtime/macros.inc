# MACROS
.equ	SYS_READ,  0
.equ	SYS_WRITE, 1
.equ	SYS_EXIT,  60
.equ	STDIN,	   0
.equ	STDOUT,	   1
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
