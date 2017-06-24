; FUNCTION: printElapsed
;
; PURPOSE: Print integer to console3
;
; CALLING CONVENTION: Linux X86_64 ABI
; r prefix for 64bit registers
;
; INPUT:
;   rdi - call parameter 1 (integer to print)

; OUTPUT:
;	None
;
; VARIABLES: The registers have the following uses
;
; rax - division of integer
; rbx - length of the buffer
; rcx - digit count
; rdx - division of integer
; rdi - divisor
;
; CONSTANTS
STDIN			equ		0
STDOUT			equ		1
STDERR			equ		2
SYS_WRITE		equ		1
BUFF_SZ			equ		80

; BUFFER SECTION
	section		.bss
	;local storage allocated at runtime
	
	buffer: 	resb	BUFF_SZ		;reserve BUFFER_SIZE bytes
				resb	0
; CODE SECTION
	global printElapsed
	extern  print
	section .text			

printElapsed:	
	push		rbp				; save stack for function return
	mov			rbp, rsp

    ; Initialize
	mov			rax, rdi		; move integer for division
	xor			rcx, rcx		; 0 the digit count
	xor			r8, r8			; zero counter for printing ','
	mov			rdi, 10			; setup for divide by 10
	mov			[buffer+BUFF_SZ], rcx	;set null terminator for string

convert:
	xor			rdx, rdx		; division done on combined rdx:rax, so 0 %rdx
	; Start dividing
	div			rdi				; quotient in %rax, remainder in %rdx
	add			rdx, '0'		; convert to ascii digit
	inc			r8             	; inc count for ','
	cmp			r8, 4         	; if processed 4 digits, print a ','
	je			addComma
nextDigit:
	push		rdx				; save digit
	inc			rcx				; increment digit count
	cmp			rax, 0		 	; if remainer is 0, we're done
	jne			convert

	; Move from stack to bufffer
	lea			rdx, [buffer]
	mov			rbx, rcx		; save the digit count
save:
	pop			rax				; get digit from stack
	mov	 		[rdx], al		; save it in the buffer
	dec			rcx				; decrement digit count
	inc			rdx				; move buffer ptr
	cmp			rcx, 0			; all digits moved?
	jne			save
	mov			[rdx], BYTE 0	; terminate string with null byte
	
	lea			rsi, [buffer]
	call		print
	
exit:
	mov 	rsp, rbp		; restore stack for function return
	pop 	rbp
	ret
addComma:
	xor		rsi, rsi      	; clear for store
    add		rsi, ','		; store ','
	push	rsi				; store ','
	inc		rcx				; increment digit count
	mov		r8, 1			; zero counter for printing ','
	jmp		nextDigit	
	