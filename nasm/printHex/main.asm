; ----------------------------------------------------------------------------------------
; Converts a byte or register to a hex string and writes it to the console using a system call
; Runs on 64-bit Linux only.
; ----------------------------------------------------------------------------------------

        global  _start

        section .text
_start:

        xor	rax, rax            	; clear rax
        mov	ax, 0x76            	; hex number in ax 
	call	printByte

        ; exit(0)
        mov     eax, 60                 ; system call 60 is exit
        xor     rdi, rdi                ; exit code 0
        syscall                         ; invoke operating system to exit

printByte:
	push	rax			; save calling registers
	push	rdi
	push	rsi
	push	rdx

	xor	rdi, rdi
	mov	r10, rax		; save byte to convert

 	shr     ax, 4			; expose high nibble
	mov	dl, [hexTable + rax] 	; get printable character in dl
	mov	byte [byteDigits], dl
	mov	rax, r10		; restore byte to convert
	and	ax, 0x0f		; clear high nibble
	mov	dl, [hexTable + rax]	; get printable character in dl
	mov	[byteDigits + 1], dl

        ; write(message, length)
        mov     rax, 1                  ; system call 1 is write
        mov     rdi, 1                  ; file handle 1 is stdout
        mov     rsi, byteMsg            ; file handle 1 is stdout
        mov     rdx, 5                  ; number of bytes
        syscall                         ; invoke operating system to do the write

	pop	rdx			; restore calling registers
	pop	rsi
	pop	rdi
	pop	rax
	ret

section	.data
byteMsg:
        db      "0x"      		; 1 byte is 2 hex digits
byteDigits:
        db      "00"      		; 1 byte is 2 hex digits
        db     	10      		; note the newline at the end
hexTable:
	db	"0123456789ABCDEF"	; hex lookup table

