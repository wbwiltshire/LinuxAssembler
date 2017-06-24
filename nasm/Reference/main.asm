; Reference impelementation for X86_64 assembler on Linux
; using Netwide Assembler (nasm) and Intel syntax
;
; Written for Linux x86_64
; %r prefix means 64 bit registers
; %e prefix means 32 bit registers
;
; Linux x86_64 system calls: http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
;
; BUFFER SECTION

; CONSTANTS
STDIN		equ		0
STDOUT		equ		1
STDERR		equ		2
SYS_WRITE	equ		1
SYS_EXIT	equ		60
FOUR_PLUS_FOUR	equ		4 + 4

; CODE SECTION
	section .text
;--- Start of main program ---
	global  _start

_start:

	; Initialiize
	mov		rbp, rsp
	
	lea		rsi, [startMsg]
	call 	print

examples:
	; Examples of moving data and address modes
%include "addressingModes.inc"

	
	lea		rsi, [endMsg]
	call 	print

	; exit(0)
	mov     eax, SYS_EXIT           ; system call 60 is exit
	xor     rdi, rdi                ; exit code 0
	syscall

; ----------------------------------------------------------------------------------------
; Prints a null terminated string with pointer in RSI
; ----------------------------------------------------------------------------------------
print:
	push    rax                     ; save calling registers
	push    rbx
	push    rcx
	push    rdx
	push    rdi
	push    rsi
	
	xor		rax, rax				; search for '\0' null terminator
	mov		rdi, rsi				; source to search
	xor		rcx, rcx				; set max search length
	not		rcx
	cld								; search forward
	repne	scasb					; search until found or end
	jnz		printExit
	not		rcx	
	dec		rcx						; compute length

	; write(message, length) - source is rsi
	mov     rax, SYS_WRITE			; system call 1 is write
	mov     rdi, STDOUT				; file handle 1 is stdout
	mov		rdx, rcx				; length of string
	syscall

printExit:
	pop		rsi			; restore calling registers
	pop		rdi
	pop		rdx
	pop		rcx
	pop		rbx
	pop		rax
	ret	
; ----------------------------------------------------------------------------------------
; DATA SECTION
; ----------------------------------------------------------------------------------------
section .data

oneb:	db		1						; 1 byte
onew:	dw		1						; 2 bytes
oned:	dd		1						; 4 bytes
oneq:	dq		1						; 8 bytes
listb:	db		1, 2, 3					; 3 bytes
listw:	dw		1, 2, 3 				; 6 bytes
listd:	dd		1, 2, 3					; 12 bytes
listq:	dq		1, 2, 3					; 24 bytes
byteMsg:
        db      "0x"                    ; 1 byte is 2 hex digits
		db		10, 10, 0					; newline
startMsg:
        db      "Starting reference..." ; Start message
		db		10, 0					; newline
endMsg:
		db		10						; newline
		db      "Reference ended."      ; End messagee
		db		10, 0					; newline		