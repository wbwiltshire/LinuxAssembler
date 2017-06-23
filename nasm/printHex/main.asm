; ----------------------------------------------------------------------------------------
; Converts a byte or register to a hex string and writes it to the console using a system call
; Runs on 64-bit Linux only.
; ----------------------------------------------------------------------------------------

        global  _start

        section .text
_start:

	xor		rax, rax            	; clear rax
	mov		ax, 0x76            	; hex number in ax 
	call	printByte
	mov		rax, 0x0123456789abcdef ; hex number in ax 
	call	printRegister

	; exit(0)
	mov     eax, 60                 ; system call 60 is exit
	xor     rdi, rdi                ; exit code 0
	syscall                         ; invoke operating system to exit

; ----------------------------------------------------------------------------------------
; Expects byte to be in AL register
; ----------------------------------------------------------------------------------------
printByte:
	push	rax				; save calling registers
	push	rdi
	push	rsi
	push	rdx

	xor	rdi, rdi
	mov	r10, rax			; save byte to convert

 	shr     ax, 4			; expose high nibble
	mov		dl, [hexTable + rax] 	; get printable character in dl
	mov		byte [byteDigits], dl
	mov		rax, r10		; restore byte to convert
	and		ax, 0x0f		; clear high nibble
	mov		dl, [hexTable + rax]	; get printable character in dl
	mov		[byteDigits + 1], dl

	; write(message, length)
	mov     rax, 1          ; system call 1 is write
	mov     rdi, 1          ; file handle 1 is stdout
	mov     rsi, byteMsg    ; message to write
	mov     rdx, 5          ; number of bytes
	syscall                 ; invoke operating system to do the write

	pop		rdx				; restore calling registers
	pop		rsi
	pop		rdi
	pop		rax
	ret
; ----------------------------------------------------------------------------------------
; Expects register value to be in RAX register
; BL hold printable hex character 
; CL holds the number of bits to shift
; Dl holds the loop count
; SI holds offset to output string 
; R8 holds bit mask
; R9 holds initial number
; ----------------------------------------------------------------------------------------
printRegister:
	push	rax			; save calling registers
	push	rbx
	push	rcx
	push	rdx
	push	rdi
	push	rsi
	push	r8
	push	r9
	
	mov		cl, 60		; set shift count
	mov		dl, 16		; set digit count
	mov		rsi, 0		; index to output
	mov		r8, 0xf		; set mask
	mov		r9, rax		; save register to convert
hexLoop:
	shr		rax, cl		; shift out high nibble
	and		rax, r8
	mov		bl, [hexTable + rax] 	; get printable character in dl
	mov		byte [registerDigits + rsi], bl
	sub		cl, 4		; decrease shift count
	inc		rsi			; move to next output char
	mov		rax, r9		; restore for iteration
	dec		dl			; decrease digit count
	jnz		hexLoop
	
    ; write(message, length)
	mov     rax, 1                  ; system call 1 is write
	mov     rdi, 1                  ; file handle 1 is stdout
	mov     rsi, registerMsg        ; message to write
	mov     rdx, 19                 ; number of bytes
	syscall 	
	
	pop		r9						; restore calling registers
	pop		r8
	pop		rsi
	pop		rdi
	pop		rdx			
	pop		rcx						
	pop		rbx						
	pop		rax
	ret
; ----------------------------------------------------------------------------------------
; DATA SECTION
; ----------------------------------------------------------------------------------------
section	.data
byteMsg:
        db      "0x"      		; 1 byte is 2 hex digits
byteDigits:
        db      "00"      		; 1 byte is 2 hex digits
        db     	10      		; note the newline at the end
registerMsg:
        db      "0x"      		; 1 byte is 2 hex digits
registerDigits:
        db      "0000000000000000"   ; 8 bytes is 16 hex digits
        db     	10      		; note the newline at the end
hexTable:
	db	"0123456789ABCDEF"	; hex lookup table

