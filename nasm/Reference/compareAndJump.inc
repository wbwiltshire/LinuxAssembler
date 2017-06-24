; PURPOSE: Provide reference examples of different compare and jump instructions

	; Unconditional jumps (short, near, far)
	; short (+ or -128)
	; near (> 128 but within segment)
	; far (different segment)
	
	jmp		nearJump
	mov		si, [dontrun]
	call	print
	
nearJump:
	jmp		farJump
		
	; Conditional jumps
	; Must have an operation that sets the EFLAGS registers
	; Flags: Zero (ZF), Parity (PF), Overflow (OF), Sign (SF), and Carry (CF)
	; Only short and near jumps are supported

nearConditional:
	xor		rax, rax
	or		rax, rax				; force flags to be updated
	jz		jeJump					; should jump since it's 0
	mov		si, [dontrun]
	call	print
	
jeJump:
	xor		rbx, rbx
	cmp		rax, rbx
	je		jlJump					; should jump since the are equal
	mov		si, [dontrun]
	call	print
	
jlJump:
	mov		rbx, 1
	cmp		rax, rbx
	jl		jgJump					; should jump since rax is less than rbx
	mov		si, [dontrun]
	call	print
	
jgJump:
	cmp		rbx, rax
	jg		jneJump					; should jump since rbx is greater than rax
	mov		si, [dontrun]
	call	print

jneJump:
	cmp		rax, rbx
	jne		jnzJump					; should jump since rax and rbx are not equal
	mov		si, [dontrun]
	call	print

jnzJump:
	or		rbx, rbx				; force flags to be updated
	jnz		jmpExit					; should jump since rbx is not zero
	mov		si, [dontrun]
	call	print

jmpExit:	
	