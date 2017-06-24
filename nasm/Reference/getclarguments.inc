; -----------------------------------------------------------------------------
; On entry the list of argument pointers will be on the stack
; -----------------------------------------------------------------------------

	lea		rbx, [argPtrs]		; setup base register
	xor		rdi, rdi			; initialize index
argloop:
	pop		rsi		 			; get next argument address to print
	mov		[rbx+rdi*8], rsi	; store pointer
	call	print             	; print it
	lea		rsi, [newline]
	call	print             	; print newline
	inc		rdi					; increment index
	cmp		[argC], rdi         ; process all arguments
	jne		argloop             ; if not done counting keep going
