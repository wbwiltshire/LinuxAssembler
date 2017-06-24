; PURPOSE: Provide reference examples of different math instructions
	
	; Addition using constants
	xor		rax, rax				; zero rax
	add		al, 8					; add 8 into al (8bit)
	add		al, BYTE 8				; same as above
	add		ax, 8					; add 8 into ax (16bit)
	add		ax, WORD 8				; same as above
	add		eax, 8					; add 8 into eax (32bit)
	add		eax, DWORD 8			; same as above
	add		rax, 8					; add 8 into rax (64bit)
	add		rax, QWORD 8			; same as above
	
	; Addition using indirect addressing mode (move a value from and address in a register)
	; Note: uses lea instruction as a functional equivalent to mov used in code above
	xor		rax, rax				; zero rax
	lea		rbx, [oneb]				; load effective address (not the value) to rbx  
	add		al, BYTE [rbx]			; add value at addess in rbx with al (8bit)
	lea		rbx, [onew]				; 
	add		ax, WORD [rbx]			; 16bit
	lea		rbx, [oned]				; 
	add		eax, DWORD [rbx]		; 32bit
	lea		rbx, [oneq]				; 
	add		rax, QWORD [rbx]		; 64bit
	
	; Addition using index base pointer addressing mode (move value using a base pointer, index, and multiplier)
									; or you can do it this way, when the list location isn't know till later
	xor		rax, rax				; zero rax
	lea		rbx, [listb]			; load effective address (not the value) to rbx  
	mov		rsi, 1					; access 2nd item in the list (0 based index)
	add		al, [rbx+rsi*1]			; load value in list into al (8bit)
	lea		rbx, [listw]			; 
	add		ax, [rbx+rsi*2]			; 16bit
	lea		rbx, [listd]			; 
	add		eax, [rbx+rsi*4]		; 32bit
	lea		rbx, [listq]			; 
	add		rax, [rbx+rsi*8]		; 64bit
	
	; Subtraction using constants
	mov		rax, 0xff				; move 255 rax
	sub		al, 8					; sub 8 into al (8 bit)
	sub		al, BYTE 8				; same as above
	sub		ax, 8					; sub 8 into ax (16 bit)
	sub		ax, WORD 8				; same as above
	sub		eax, 8					; sub 8 into eax (32 bit)
	sub		eax, DWORD 8			; same as above
	sub		rax, 8					; sub 8 into rax (64 bit)
	sub		rax, QWORD 8			; same as above
	
	;;;
	;;; MULTIPLICATION ;;;
	;;;
	; Unsigned Multiplication using direct mode
	mov		al, 4
			; NOTE: Can't multiply 8 bit registers, since 8 bits is too small to hold result
	;mul	al, 4					; NOT ALLOWED
	mov		bl, 4					; move 4 to bl
	mul		bl						; implied register is al and result in al (8 bit)
	mul		bx						; implied register is ax and result in ax (16 bit)
	mul		ebx						; implied register is eax and result in eax (32 bit)
	mul		rbx						; implied register is rax and result in rax (64 bit)
	; Unsigned Multiplication using indirect mode
	mul		BYTE [oneb]				; implied register is al and result in al (8 bit)
	mul		WORD [onew]				; (16 bit)
	mul		DWORD [oned]			; (32 bit)
	mul		QWORD [oneq]			; (64 bit)
	
	; Signed Multiplication using direct mode
	mov		ax, 4					; move 4 to ax
			; NOTE: Can't multiply 8 bit registers, since 8 bits is too small to hold result
	;imul	al, 4					; NOT ALLOWED
	imul	ax, 4					; multiply ax by 4 (16 bit) - result in ax
	imul	eax, 4					; multiply eax by 4 (32 bit) - result in eax
	imul	rax, 4					; multiply rax by 4 (64 bit) - result in rax

	; Signed Multiplication using indirect mode
	imul	BYTE [oneb]				; implied register is al and result in ax (16 bit)
	imul	WORD [onew]				; (16 bit)
	imul	DWORD [oned]			; (32 bit)
	imul	QWORD [oneq]			; (64 bit)
	
	;;;
	;;; DIVISION ;;;
	;;;
		; NOTE: Can't divide by constants; must use registers
		
	; Unsigned Division using direct mode
		; DIVIDEND in the following registers:
			; ax
			; dx:ax
			; edx:eax
			; rdx:rax
		; DIVISOR in any other registers or memory location
		; QUOTIENT in the following registers:
			; al (8 bit)
			; ax (16 bit)
			; eax (32 bit)
			; rax (64 bit)
		; REMAINDER in the following registers:
			; ah
			; dx
			; edx
			; rdx

	mov		rax, 16
	mov		rbx, 4					; move 4 to bl
	div		bl						; implied register is ax and quotient in al (8 bit) and remainer in ah
	mov		rax, 16
	div		bx						; implied register is ax and result in ax:dx (16 bit)
	mov		rax, 16
	div		ebx						; implied register is eax and result in eax:edx (32 bit)
	mov		rax, 16
	div		rbx						; implied register is rax and result in rax:rdx (64 bit)
	; Unsigned Division using indirect mode
	mov		rax, 16
	div		BYTE [oneb]				; implied register is ax and quotient in al (8 bit) and remainer in ah
	div		WORD [onew]				; (16 bit)
	div		DWORD [oned]			; (32 bit)
	div		QWORD [oneq]			; (64 bit)
	
	; Signed Division using direct mode
	mov		rax, 16
	mov		rbx, 4					; move 4 to bl
	idiv	bl						; implied register is ax and quotient in al (8 bit) and remainer in ah
	mov		rax, 16
	idiv	bx						; implied register is ax and result in ax:dx (16 bit)
	mov		rax, 16
	idiv	ebx						; implied register is eax and result in eax:edx (32 bit)
	mov		rax, 16
	idiv	rbx						; implied register is rax and result in rax:rdx (64 bit)

	; Signed Division using indirect mode
	mov		rax, 16
	idiv	BYTE [oneb]				; implied register is al and result in ax (16 bit)
	idiv	WORD [onew]				; (16 bit)
	idiv	DWORD [oned]			; (32 bit)
	idiv	QWORD [oneq]			; (64 bit)
	