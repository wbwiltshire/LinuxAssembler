; -----------------------------------------------------------------------------
; A 64-bit program that displays its command line arguments, one per line.
;
; On entry, rdi will contain argc and rsi will contain argv.
; -----------------------------------------------------------------------------

        global  main
        extern  puts
        section .text
main:
        pop	rcx 	                ; grab argument count

loop:
        pop	rdi		 	; get next argument address
        call	print                   ; print it
        dec	rcx                     ; count down
        jnz	loop                    ; if not done counting keep going

        ; exit(0)
        mov	eax, 60                 ; system call 60 is exit
        xor	rdi, rdi                ; exit code 0
        syscall  
print:
	push	rcx
        call	puts                    ; print it
	pop	rcx
	ret	
