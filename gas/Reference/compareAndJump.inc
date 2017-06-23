# PURPOSE: Provide reference examples of different compare and jump instructions

	# Unconditional jumps (short, near, far)
	# short (+ or -128)
	# near (> 128 but within segment)
	# far (different segment)
	
	jmp		nearJump
	SYSPRINT $dontrun, $drlen
	
nearJump:
	jmp		farJump
		
	# Conditional jumps
	# Must have an operation that sets the EFLAGS registers
	# Flags: Zero (ZF), Parity (PF), Overflow (OF), Sign (SF), and Carry (CF)
	# Only short and near jumps are supported
	
nearConditional:
	xor		%rax, %rax
	or		%rax, %rax				# force flags to be updated
	jz		jeJump					# should jump since it's 0
	SYSPRINT $dontrun, $drlen
	
jeJump:
	xor		%rbx, %rbx
	cmp		%rbx, %rax
	je		jlJump					# should jump since the are equal
	SYSPRINT $dontrun, $drlen
	
jlJump:
	mov		$1, %rbx
	cmp		%rbx, %rax
	jl		jgJump					# should jump since rax is less than rbx
	SYSPRINT $dontrun, $drlen
	
jgJump:
	cmp		%rax, %rbx
	jg		jneJump					# should jump since rbx is greater than rax
	SYSPRINT $dontrun, $drlen

jneJump:
	cmp		%rbx, %rax
	jne		jnzJump					# should jump since rax and rbx are not equal
	SYSPRINT $dontrun, $drlen

jnzJump:
	or		%rbx, %rbx				# force flags to be updated
	jnz		jmpExit					# should jump since rbx is not zero
	SYSPRINT $dontrun, $drlen

jmpExit:
