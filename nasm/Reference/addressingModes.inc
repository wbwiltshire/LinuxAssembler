; PURPOSE: Provide reference examples of different addressing modes

	; Format = ADDRESS_OR_OFFSET(%BASE_OR_OFFSET,%INDEX,MULTIPLIER)
	; Address = ADDRESS_OR_OFFSET + %BASE_OR_OFFSET + (%INDEX * MULTIPLIER)
	
	; Immediate mode (move constants)
	mov		al, 8					; load 8 into al (8bit)
	;mov	ax, $4 + $4				;;; THIS DOESN'T WORK
	mov		ax, FOUR_PLUS_FOUR		; BUT THIS DOES WORK
	mov		eax, 8					; 32bit
	mov		rax, 8					; 64bit
	
	mov		al, BYTE 8				; load 8 into al (8 bit)
	mov		ax, WORD 8				; 16 bit
	mov		eax, DWORD 8			; 32 bit
	mov		rax, QWORD 8			; 64 bit	
	
	; Direct addressing mode (move value of a variable)
	mov		al, [oneb]				; load value at oneb into al (8bit)
	mov		ax, [onew]				; 16 bit
	mov		eax, [oned]				; 32 bit
	mov		rax, [oneq]				; 64 bit

	mov		al, BYTE [oneb]			; load value at oneb into al (8 bit)
	mov		ax, WORD [onew]			; 16 bit
	mov		eax, DWORD [oned]		; 32 bit
	mov		rax, QWORD [oneq]		; 64 bit
	
	; Indexed addressing mode (move a value in a list using an index and multiplier)
	; when the address of the list is at a fixed location
	mov		rsi, 1					; access 2nd item in the list (0 based index)
	mov		al, [listb + rsi]		; load value in list into al (8bit)
	mov		ax, [listw + rsi]		; 16 bit
	mov		eax, [listd + rsi]		; 32 bit
	mov		rax, [listq + rsi]		; 64 bit
	
	; Full version of the indexed base pointer format
	; base=rbx, index=rsi, scale=8
	mov		rsi, 1					; access 2nd item in the list (0 based index)
	mov		rbx, 0					; this could be a secondary index or a base pointer
	mov		rax, [listq+rbx+rsi*8]	; 64bit
	
	; Index base pointer addressing mode (move value using a base pointer, index, and multiplier)
	lea		rbx, [listb]			; load address into base register
	mov		rsi, 1					; access 2nd item in the list (0 based index)
	mov		al, [rbx+rsi*1]			; load value in list into al (8bit)
	lea		rbx, [listw]			; load address into base register
	mov		ax, [rbx+rsi*2]			; 16 bit
	lea		rbx, [listd]			; load address into base register
	mov		eax, [rbx+rsi*4]		; 32 bit
	lea		rbx, [listq]			; load address into base register
	mov		rax, [rbx+rsi*8]		; 64 bit
	
	; Indirect addressing mode (move a value from an address into a register)
	; Note: uses lea instruction as a functional equivalent to mov used in code above
	mov		rbx, oneb				; load effective address (not the value) to rbx 
	lea		rbx, [oneb]				; this is equavilent to the line above 
	mov		al, [rbx]				; 8 bit
	lea		rbx, [onew]				; load effective address (not the value) to rbx 
	mov		ax, [rbx]				; 16 bit
	lea		rbx, [oned]				; load effective address (not the value) to rbx 
	mov		eax, [rbx]				; 32 bit
	lea		rbx, [oneq]				; load effective address (not the value) to rbx 
	mov		rax, [rbx]				; 64 bit
