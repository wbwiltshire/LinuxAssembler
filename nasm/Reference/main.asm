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
STDIN			equ		0
STDOUT			equ		1
STDERR			equ		2
SYS_WRITE		equ		1
SYS_EXIT		equ		60
FOUR_PLUS_FOUR	equ		4 + 4
BUFFER_SIZE		equ		512
ARG_COUNT		equ		2
SYS_GET_TOD		equ		96

; BUFFER SECTION
	section		.bss
	;local storage allocated at runtime
	
	BUFFER_DATA: 	resb	BUFFER_SIZE		;reserve BUFFER_SIZE bytes
	destination:	resb 	11
	destinationRep: resb	11
	destinationStos: resb	11	

; CODE SECTION
	section .text
;--- Start of main program ---
	global  _start, print
	extern  printf, printElapsed

_start:

	; Initialiize
	mov		rbp, rsp
	
	; Capture start time
	lea     rdi, [startTime]        ; pointer to timeval structure
	xor     rsi, rsi                ; pointer to timezone structure (should be null)
	mov     rax, SYS_GET_TOD      	; sys/gettimeofday system call
	syscall                         ; Make system call
	
	; Get command line arguments
	pop		rcx					; pop the argument count into rcx
	mov		[argC], rcx			; store the count
	cmp		rcx, ARG_COUNT
	jnz		usage
	
	lea		rsi, [startMsg]
	call 	print
	
	; Handle command line arguments
	%include "getclarguments.inc"


examples:
	; Examples of moving data and address modes
	%include "addressingModes.inc"

	; Examples of different jumps and compares
	%include	"compareAndJump.inc"
	
	; Example of strings
	%include	"stringStuff.inc"
	
	; Examples of math instructions (addition, subtraction, multiplication, and division)
	%include "mathinstructions.inc"
	
	; Call printf "C" library function
	;Note: printf may destroy rax and rcx, so we'll save them before the call
	push	rax
	push	rcx
	lea		rdi, [cMessage2]		; set 1st parameter (format string)
	lea		rsi, [cParm2]			; set 2st parameter (first variable)
	xor		rax, rax				; because printf is varargs
    call    printf 
	pop		rcx
	pop		rax
	
	lea		rsi, [endMsg]
	call 	print

exit:

	; Capture end time
	lea		rsi, [newline]
	call	print
	lea		rsi, [elapsedMsg]
	call	print
	lea		rdi, [endTime]          ; pointer to timeval structure
	xor     rsi, rsi                ; pointer to timezone structure (should be null)
	mov     rax, SYS_GET_TOD      	; sys/gettimeofday system call
	syscall                         ; Make system call
	mov     rax, [endSecs]          ; Move seconds for substract
    sub     rax, [startSecs]        ; Difference is elapsed time in usecs
	mov     rcx, 1000000          	; Adjust for 1M microseconds/second
	mul     rcx                    	; mul will multiplie rcx * rax 			
									; result in rax (least significant) and rdx
									
	mov     rdi, [endMSecs]         ; Move for substract
	sub     rdi, [startMSecs]       ; Difference is elapsed time in usecs
	add		rdi, rax              	; Add in the difference in seconds
	call	printElapsed
	lea		rsi, [newline]			; rdi has elapsed time
	call	print
	
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
usage:
	lea		rsi, [usageMsg]
	call	print
	jmp	exit	
; 	Far jump for compareAndJump
;org		0x9000
farJump:
	lea		rsi, [farJumpMsg]
	call	print
	jmp		nearConditional	
; ----------------------------------------------------------------------------------------
; DATA SECTION
; ----------------------------------------------------------------------------------------
section .data
argC:	dq		0						; hold command line argument count
argPtrs:								; table of argument addresses 
	TIMES ARG_COUNT	dq   	0
startTime:
	startSecs:		dq 		0
	startMSecs:		dq		0
endTime:
	endSecs:		dq		0
	endMSecs:		dq		0	
oneb:	db		1						; 1 byte
onew:	dw		1						; 2 bytes
oned:	dd		1						; 4 bytes
oneq:	dq		1						; 8 bytes
listb:	db		1, 2, 3					; 3 bytes
listw:	dw		1, 2, 3 				; 6 bytes
listd:	dd		1, 2, 3					; 12 bytes
listq:	dq		1, 2, 3					; 24 bytes
newline:
		db		10, 0					; newline
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
dontrun:
		db		"Oops!"					; shouldn't run message
		db		10, 0
farJumpMsg:	
		db		"Jumped far!"			; far jump message
		db		10, 0
cMessage:			
		db		10, "Printed from C library!"
		db		10, 0
cMessage2:
		db		"Hello %s!"
		db		10, 0
cParm2:
		db		"World"
		db		0
elapsedMsg:	
		db		"Elapsed time(us): "
		db		0
usageMsg:		
		db		"Usage: reference <infile>"
		db		10, 0
sourceString:		
		db		"012345689"				; string	
